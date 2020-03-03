RSpec.describe DataExports::DataStorage do
  let(:project) { create(:project, slug: "lizard_king/underground_fortress") }
  let(:workflow) { create(:workflow, project: project)}
  let(:transcription) { create(:transcription, workflow: workflow, group_id: "ROACH_WARRIORS") }
  let(:another_transcription) { create(:transcription, group_id: "ROACH_WARRIORS") }
  let(:transcription_group) { [transcription, another_transcription] }

  let(:data_storage) { described_class.new }

  describe '#zip_transcription_files' do
    it 'throws error when no stored files are found' do
      expect { data_storage.zip_transcription_files(transcription) }.to raise_error(DataExports::NoStoredFilesFoundError)
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
    end
  end

  describe '#zip_group_files' do
    before(:each) do
      transcription.export_files.attach(blank_file_blob)
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