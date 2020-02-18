require 'csv'

RSpec.describe DataExports::AggregateMetadataFileGenerator do
  let (:project) { create(:project, slug: "lizard_king/underground_fortress") }
  let(:workflow) { create(:workflow, project: project)}
  let(:transcription) { create(:transcription, :unedited_json_blob, workflow: workflow, group_id: "ROACH_WARRIORS") }
  let(:another_transcription) { create(:transcription, :unedited_json_blob, workflow: workflow, group_id: "ROACH_WARRIORS") }
  let(:transcription_group) { [transcription, another_transcription] }

  let(:parent_dir) { Dir.mktmpdir }
  let(:csv_filepath) { File.join(parent_dir, 'transcriptions_metadata.csv')}

  let(:metadata_file_gen) { described_class.new(parent_dir) }

  before(:each) do
    transcription.files.attach(transcription_metadata_blob)
    another_transcription.files.attach(transcription_metadata_blob)
  end

  describe '#generate_group_file' do
    before(:each) do
      metadata_file_gen.generate_group_file(transcription_group)
    end

    after(:each) do
      FileUtils.rm_rf(parent_dir)
    end

    it 'creates a csv file in the expected location' do
      expect(File).to exist(csv_filepath)
    end

    it 'creates a csv with the expected header' do
      rows = CSV.read(csv_filepath)
      expect(rows.first).to eq([
        'name','class','weapon'
      ])
    end

    it 'creates a csv with a header and one row per transcription with metadata' do
      rows = CSV.read(csv_filepath)
      expect(rows.length).to eq(3)
    end
  end

  describe '#generate_workflow_file' do
    before(:each) do
      metadata_file_gen.generate_workflow_file(workflow)
    end

    after(:each) do
      FileUtils.rm_rf(parent_dir)
    end

    it 'creates a csv file in the expected location' do
      expect(File).to exist(csv_filepath)
    end

    it 'creates a csv with a header and one row per transcription with metadata' do
      rows = CSV.read(csv_filepath)
      expect(rows.length).to eq(3)
    end
  end

  describe '#generate_project_file' do
    before(:each) do
      metadata_file_gen.generate_project_file(project)
    end

    after(:each) do
      FileUtils.rm_rf(parent_dir)
    end

    it 'creates a csv file in the expected location' do
      expect(File).to exist(csv_filepath)
    end

    it 'creates a csv with a header and one row per transcription with metadata' do
      rows = CSV.read(csv_filepath)
      expect(rows.length).to eq(3)
    end
  end
end