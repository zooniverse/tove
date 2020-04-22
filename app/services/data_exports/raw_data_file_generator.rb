module DataExports
  module RawDataFileGenerator
    private

    # creates raw data file as tempfile,
    # returns tempfile
    def write_raw_data_to_file
      file = Tempfile.new(["raw_data_#{@transcription.id}-", '.json'])
      file.write(@transcription.text.to_json)
      file.rewind

      file
    end
  end
end
