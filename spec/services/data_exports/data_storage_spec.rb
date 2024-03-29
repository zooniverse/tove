RSpec.describe DataExports::DataStorage do
  let(:project) { create(:project, slug: "lizard_king/underground_fortress") }
  let(:workflow) { create(:workflow, project: project)}
  let(:transcription) { create(:transcription, workflow: workflow, group_id: "ROACH_WARRIORS") }
  let(:another_transcription) { create(:transcription, group_id: "ROACH_WARRIORS") }
  let(:transcription_group) { [transcription, another_transcription] }

  let(:data_storage) { described_class.new }

  describe '#zip_transcription_files' do
    it 'throws error when no stored files are found' do
      expect { data_storage.zip_transcription_files(transcription) }.to raise_error(DataExports::DataStorage::NoStoredFilesFoundError)
    end

    context 'when stored files are found' do
      before(:each) do
        transcription.export_files.attach(blank_file_blob)
      end

      it "produces a zip file named export.zip" do
        data_storage.zip_transcription_files(transcription) do |zip_file|
          expect(zip_file).to be_a(String)
          expect(File.basename(zip_file)).to eq('export.zip')
          expect(File).to exist(zip_file)
        end
      end

      it "generates a custom message with file details when there is an UndefinedConversionError" do
        bad_encoding_file = instance_double(File)
        allow(bad_encoding_file).to receive(:write) { raise Encoding::UndefinedConversionError.new('xCB from ASCII-8BIT to UTF-8') }
        allow(bad_encoding_file).to receive(:close)
        allow(File).to receive(:open) { bad_encoding_file }

        expect { data_storage.zip_transcription_files(transcription) {} }.to raise_error(Encoding::UndefinedConversionError, /^xCB from ASCII-8BIT to UTF-8. Filename: transcription_file.txt, Blob path: [a-zA-Z0-9]*, Blob id: [0-9]*$/)
      end
    end
  end

  describe '#zip_group_files' do
    before(:each) do
      transcription.export_files.attach(blank_file_blob)
      allow(DataExports::AggregateMetadataFileGenerator).to receive(:generate_group_file).and_return(true)
    end

    it "produces a zip file named export.zip" do
      data_storage.zip_group_files(transcription_group) do |zip_file|
        expect(zip_file).to be_a(String)
        expect(File.basename(zip_file)).to eq('export.zip')
        expect(File).to exist(zip_file)
      end
    end
  end

  describe '#zip_workflow_files' do
    before(:each) do
      transcription.export_files.attach(blank_file_blob)
      allow(DataExports::AggregateMetadataFileGenerator).to receive(:generate_workflow_file).and_return(true)
    end

    it "produces a zip file named export.zip" do
      data_storage.zip_workflow_files(workflow) do |zip_file|
        expect(zip_file).to be_a(String)
        expect(File.basename(zip_file)).to eq('export.zip')
        expect(File).to exist(zip_file)
      end
    end
  end

  describe '#zip_project_files' do
    before(:each) do
      transcription.export_files.attach(blank_file_blob)
      allow(DataExports::AggregateMetadataFileGenerator).to receive(:generate_project_file).and_return(true)
    end

    it "produces a zip file named export.zip" do
      data_storage.zip_project_files(project) do |zip_file|
        expect(zip_file).to be_a(String)
        expect(File.basename(zip_file)).to eq('export.zip')
        expect(File).to exist(zip_file)
      end
    end
  end
end