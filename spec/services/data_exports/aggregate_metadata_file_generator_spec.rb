RSpec.describe DataExports::AggregateMetadataFileGenerator do
  let(:transcription) { create(:transcription, group_id: "ROACH_WARRIORS") }
  let(:another_transcription) { create(:transcription, group_id: "ROACH_WARRIORS") }
  let(:transcription_group) { [transcription, another_transcription] }

  let(:parent_dir) { Dir.mktmpdir }
  let(:csv_filepath) { File.join(parent_dir, 'transcriptions_metadata.csv')}

  let(:metadata_file_gen) { described_class.new(parent_dir) }

  describe '#generate_group_file' do
    before(:each) do
      transcription.files.attach(create_file_blob)
      another_transcription.files.attach(create_file_blob)
    end

    it 'creates a csv file in the expected location' do
      metadata_file_gen.generate_group_file(transcription_group)
      expect(File).to exist(csv_filepath)
      FileUtils.rm_rf(parent_dir)
    end
  end
end