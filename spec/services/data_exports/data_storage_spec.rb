RSpec.describe DataExports::DataStorage do
  let(:project) { create(:project, slug: "lizard_king/underground_fortress") }
  let(:workflow) { create(:workflow, project: project)}
  let(:transcription) { create(:transcription, workflow: workflow, group_id: "ROACH_WARRIORS") }
  let(:another_transcription) { create(:transcription, group_id: "ROACH_WARRIORS") }
  let(:transcription_group) { [transcription, another_transcription] }

  let(:data_storage) { described_class.new }

  shared_examples "generated zip file" do
    it { is_expected.to be_a(String) }
    it { is_expected.to match(/(\/data_exports_temp\/downloaded_files\/)/) }
    it { is_expected.to match(/\.zip$/) }
  end

  describe '#zip_transcription_files' do
    it 'throws error when no stored files are found' do
      expect { data_storage.zip_transcription_files(transcription) }.to raise_error(DataExports::NoStoredFilesFoundError)
    end

    context 'when stored files are found' do
      before(:each) do
        transcription.files.attach(blank_file_blob)
      end

      subject { data_storage.zip_transcription_files(transcription) }
      it_behaves_like "generated zip file"
    end
  end

  describe '#zip_group_files' do
    before(:each) do
      transcription.files.attach(blank_file_blob)
    end

    subject { data_storage.zip_group_files(transcription_group) }
    it_behaves_like "generated zip file"
  end

  describe '#zip_workflow_files' do
    before(:each) do
      transcription.files.attach(blank_file_blob)
    end

    subject { data_storage.zip_workflow_files(workflow) }
    it_behaves_like "generated zip file"
  end

  describe '#zip_project_files' do
    before(:each) do
      transcription.files.attach(blank_file_blob)
    end

    subject { data_storage.zip_project_files(project) }
    it_behaves_like "generated zip file"
  end
end