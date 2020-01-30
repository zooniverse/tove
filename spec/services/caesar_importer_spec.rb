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

  let(:data) {
    {
      "frame0": ["test"],
      "frame1": ["notempty"],
      "low_consensus_lines": 10,
      "transcribed_lines": 100,
      "reducer": "poly_line_text_reducer",
      "parameters": {"eagle_one": "fox_two"}
    }
  }
  let(:args) {
    {
      reduction_id: 123,
      reducible: {id: parsed_workflow[:id], type: 'Workflow'},
      data: data,
      subject: {id: 999, metadata: {"group_id": "GROUPX", "internal_id": "INTERNALID"}}
    }
  }
  let(:importer) { described_class.new(args)}

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
    end

    context 'when the project exists, but not the workflow' do
      let!(:existing_project) { create(:project, id: parsed_project[:id], slug: parsed_project[:slug]) }

      it 'creates the workflow and transcription' do
        expect{ importer.process }
          .to change{Project.count}.by(0)
          .and change{Workflow.count}.by(1)
          .and change{Transcription.count}.by(1)
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
    end

    context 'when a transcription with the same id exists' do
      let!(:existing_t) { create(:transcription, id: args[:subject][:id])}
      it 'raises a ResourceExists exception' do
        expect{importer.process}.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe 'Panoptes API implementation' do
    it 'pulls the workflow from the API' do
      api_double = instance_double(PanoptesApi)
      allow(api_double).to receive(:workflow).and_return(linked_workflow)
      allow(PanoptesApi).to receive(:new).and_return(api_double)

      expect(PanoptesApi).to receive(:new).with(token: nil, admin: true)
      expect(api_double).to receive(:workflow).with(linked_workflow[:id], {:include_project=>true})
      importer.process
    end
  end
end
