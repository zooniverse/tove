RSpec.describe DataExports::DataStorage do
  describe '#resource_files_zip' do
    let(:transcription) { create(:transcription) }
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

    context 'when zipping a workflow' do
      # to do
    end

    context 'when zipping a project' do
      # to do
    end
  end
end