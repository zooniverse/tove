require 'csv'
require 'json'

module DataExports
  class TranscriptionFileGenerator
    include DataExports::RawDataFileGenerator
    include DataExports::ConsensusTextFileGenerator
    include DataExports::MetadataFileGenerator
    include DataExports::LineMetadataFileGenerator

    def initialize(transcription)
      @transcription = transcription
    end

    def generate_transcription_files
      [
        write_raw_data_to_file,
        write_consensus_text_to_file,
        write_metadata_to_file,
        write_line_metadata_to_file
      ]
    end
  end
end
