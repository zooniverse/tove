RSpec.describe CaesarImporter, type: :service do
  let(:parsed_workflow) { { :id => 2660, :display_name => "A Frozen Workflow"} }
  let(:parsed_project) { { :id => 1715, :slug => "zwolf/ztest" } }
  let(:linked_workflow) {
    {
      id: parsed_workflow[:id],
      display_name: parsed_workflow[:display_name],
      project: parsed_project
    }
  }

  # ActionController::Parameter objects are hashes w/ indfferent access
  let(:data) {
    {
      frame0: ["test"],
      frame1: ["notempty"],
      low_consensus_lines: 10,
      transcribed_lines: 100,
      reducer: "poly_line_text_reducer",
      parameters: {"eagle_one" => "fox_two"}
    }.with_indifferent_access
  }

  let(:metadata) { {group_id: "GROUPX", internal_id: "INTERNALID"}.with_indifferent_access }
  let(:subject) { { id: 999, metadata: metadata } }

  let(:transcription_attrs) {
    {
      id: 999,
      workflow_id: parsed_workflow[:id],
      status: 'unseen',
      text: data,
      metadata: metadata,
      group_id: 'GROUPX',
      internal_id: 'INTERNALID',
      low_consensus_lines: 10,
      total_lines: 100,
      reducer: data["reducer"],
      parameters: data["parameters"],
      total_pages: 2
    }
  }

  let(:importer) { described_class.new(
    id: 123,
    reducible: {id: parsed_workflow[:id], type: 'Workflow'},
    data: data,
    subject: subject
  )}

  context 'the reducible is not a workflow' do
    it 'raises an error' do
      expect {
        described_class.new(
          id: 123,
          reducible: {id: 666, type: 'Project'},
          data: data,
          subject: subject
        )
      }.to raise_error(CaesarImporter::ReducibleError)
    end
  end

  describe '#process' do
    before do
      allow(importer).to receive(:pull_wf_and_project).and_return(linked_workflow)
    end

    context 'when neither workflow nor project exist' do
      it 'creates all resources' do
        expect{ importer.process }
          .to change{Project.count}.by(1)
          .and change{Workflow.count}.by(1)
          .and change{Transcription.count}.by(1)
      end

      it 'generates the correct resources' do
        importer.process
        t = Transcription.find(transcription_attrs[:id])
        transcription_attrs.each { |key, value| expect(t.send(key)).to eq(value) }
        expect(Project.find(parsed_project[:id])).to be_valid
        expect(Workflow.find(parsed_workflow[:id])).to be_valid
      end
    end

    context 'when the project exists, but not the workflow' do
      let!(:existing_project) { create(:project, id: parsed_project[:id], slug: parsed_project[:slug]) }

      it 'creates the workflow and transcription' do
        expect{ importer.process }
          .to change{Project.count}.by(0)
          .and change{Workflow.count}.by(1)
          .and change{Transcription.count}.by(1)
      end

      it 'generates the correct transcription and workflow' do
        importer.process
        t = Transcription.find(transcription_attrs[:id])
        transcription_attrs.each { |key, value| expect(t.send(key)).to eq(value) }
        expect(Workflow.find(parsed_workflow[:id])).to be_valid
      end
    end

    context 'when both the workflow and project exist' do
      let!(:existing_project) { create(:project, id: parsed_project[:id], slug: parsed_project[:slug]) }
      let!(:existing_workflow) { create(:workflow,
          id: parsed_workflow[:id],
          display_name: parsed_workflow[:display_name],
          project: existing_project
      )}

      it 'creates the workflow and transcription' do
        expect{ importer.process }
          .to change{Project.count}.by(0)
          .and change{Workflow.count}.by(0)
          .and change{Transcription.count}.by(1)
      end

      it 'generates the correct transcription' do
        importer.process
        t = Transcription.find(transcription_attrs[:id])
        transcription_attrs.each { |key, value| expect(t.send(key)).to eq(value) }
      end

      describe 'mixed-case metadata fields' do
        let(:new_metadata) { { 'group_ID' => "15584", 'internal_ID' => "commonwealth:2z10z979z"}.with_indifferent_access }
        let(:new_subject) { { id: 999, metadata: new_metadata } }
        let(:new_importer) { described_class.new(
          id: 123,
          reducible: {id: parsed_workflow[:id], type: 'Workflow'},
          data: data,
          subject: new_subject
        )}

        it 'correctly imports group and internal ids' do
          new_importer.process
          t = Transcription.find(transcription_attrs[:id])
          expect(t.group_id).to eq("15584")
          expect(t.internal_id).to eq("commonwealth:2z10z979z")
        end
      end
    end

    context 'when a transcription with the same id exists' do
      let!(:existing_t) { create(:transcription, id: subject[:id]) }
      it 'raises a ResourceExists exception' do
        expect{importer.process}.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe 'Panoptes API implementation' do
    it 'pulls the workflow from the API' do
      api_double = instance_double(ClientPanoptesApi)
      allow(api_double).to receive(:workflow).and_return(linked_workflow)
      allow(ClientPanoptesApi).to receive(:new).and_return(api_double)

      expect(ClientPanoptesApi).to receive(:new)
      expect(api_double).to receive(:workflow).with(linked_workflow[:id], {:include_project=>true})
      importer.process
    end
  end
end
