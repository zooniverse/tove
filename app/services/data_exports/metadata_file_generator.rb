module DataExports
  module MetadataFileGenerator
    private

    # creates transcription metadata file,
    # returns location of the file
    def write_metadata_to_file
      file = Tempfile.new(["transcription_metadata_#{@transcription.id}-", '.csv'])

      CSV.open(file.path, 'wb') do |csv|
        transcription_metadata.each do |csv_line|
          csv << csv_line
        end
      end

      file.rewind
      file
    end

    # retrieve and return transcription metadata formatted as
    # array of csv lines
    def transcription_metadata
      csv_lines = []
      csv_lines << [
        'transcription id',
        'internal id',
        'reducer',
        'caesar parameters',
        'date approved',
        'user who approved',
        'text edited (T/F)',
        'number of pages'
      ]
      csv_lines << [
        @transcription.id,
        @transcription.internal_id,
        @transcription.reducer,
        @transcription.parameters,
        @transcription.updated_at,
        @transcription.updated_by,
        is_text_edited?,
        @transcription.total_pages
      ]
    end

    def is_text_edited?
      # iterate through each 'frame' aka 'page' of transcription
      frame_regex = /^frame/
      @transcription.text.any? do |key, lines|
        frame_regex.match(key) && lines.any? { |line| line['edited_consensus_text'].present? }
      end
    end
  end
end
