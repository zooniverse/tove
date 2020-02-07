RSpec.describe DataExports::DataStorage do
  describe '#resource_files_zip' do
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

    context 'when zipping a single transcription' do
      it 'throws error when no stored files are found' do
        expect { data_storage.resource_files_zip(transcription) }.to raise_error(DataExports::NoStoredFilesFoundError)
      end

      context 'when stored files are found' do
        before(:each) do
          transcription.files.attach(create_file_blob)
        end

        subject { data_storage.resource_files_zip(transcription) }
        it_behaves_like "generated zip file"
      end
    end

    context 'when zipping a collection of transcriptions' do
      before(:each) do
        transcription.files.attach(create_file_blob)
      end

      context 'when zipping a transcription group' do
        subject { data_storage.resource_files_zip(transcription_group) }
        it_behaves_like "generated zip file"
      end

      context 'when zipping a workflow' do
        subject { data_storage.resource_files_zip(workflow) }
        it_behaves_like "generated zip file"
      end

      context 'when zipping a project' do
        subject { data_storage.resource_files_zip(project) }
        it_behaves_like "generated zip file"
      end
    end
  end
end