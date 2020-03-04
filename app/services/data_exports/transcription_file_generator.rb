require 'csv'

module DataExports
  class TranscriptionFileGenerator
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

    private

    # Private: creates raw data file as tempfile,
    # returns tempfile
    def write_raw_data_to_file
      file = Tempfile.new(["raw_data_#{@transcription.id}-", '.json'])
      file.write(@transcription.text)
      file.rewind

      file
    end

    # Private: creates consensus text file,
    # returns location of the file
    def write_consensus_text_to_file
      file = Tempfile.new(["consensus_text_#{@transcription.id}-", '.txt'])
      file.write(consensus_text)
      file.rewind

      file
    end

    # Private: retrieves and returns consensus text
    def consensus_text
      full_consensus_text = ''
      frame_regex = /^frame/

      # if we find a frame, iterate through the lines of the frame
      frames = @transcription.text.filter { |key, _value| frame_regex.match(key) }
      frames.each_value do |value|
        value.each do |line|
          line_text = if line['edited_consensus_text'].present?
                        line['edited_consensus_text']
                      else
                        line_text = line['consensus_text']
                      end

          full_consensus_text.concat line_text + '\n'
        end
        # new line after every frame
        full_consensus_text.concat '\n'
      end

      full_consensus_text
    end

    # Private: creates transcription metadata file,
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

    # Private: creates transcription line metadata file,
    # returns location of the file
    def write_line_metadata_to_file
      file = Tempfile.new(["transcription_line_metadata_#{@transcription.id}-", '.csv'])

      CSV.open(file.path, 'wb') do |csv|
        transcription_line_metadata.each do |csv_line|
          csv << csv_line
        end
      end

      file.rewind
      file
    end

    # Private: retrieve and return transcription metadata formatted as
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

    # Private: retrieve and return transcription line metadata formatted as
    # array of csv lines
    def transcription_line_metadata
      csv_lines = []
      csv_lines << [
        'consensus text',
        'line number',
        'line slope',
        'consensus score',
        'line edited (T/F)',
        'original transcriber username',
        'line editor username',
        'flagged for low consensus (T/F)',
        'page number',
        'column',
        'number of transcribers',
        'line coordinates'
      ]

      frame_regex = /^frame/
      @transcription.text.filter { |key, _value| frame_regex.match(key) }
                         .each_with_index do |(key, value), page_index|
        # if we find a frame, iterate through the lines of the frame
        page = page_index + 1

        value.each_with_index do |line, line_index|
          line_number = line_index + 1
          column = line['gutter_label'] + 1
          num_transcribers = line['user_ids'].count
          line_coordinates = {
            'clusters_x': line['clusters_x'],
            'clusters_y': line['clusters_y']
          }
          line_edited = line['edited_consensus_text'].present?
          consensus_text = line_edited ? line['edited_consensus_text'] : line['consensus_text']

          csv_lines << [
            consensus_text,
            line_number,
            line['line_slope'],
            line['consensus_score'],
            line_edited,
            line['original_transcriber'],
            line['line_editor'],
            line['low_consensus'],
            page,
            column,
            num_transcribers,
            line_coordinates
          ]
        end
      end

      csv_lines
    end
  end
end