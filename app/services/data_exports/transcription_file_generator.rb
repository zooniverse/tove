require 'csv'
require 'json'

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
      file.write(@transcription.text.to_json)
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
      frame_regex = /^frame/

      frames = @transcription.text.filter { |key, _value| frame_regex.match(key) }
      if @transcription.frame_order.present?
        full_consensus_text = retrieve_text_by_frame_order(@transcription.frame_order, frames)
      else
        full_consensus_text = retrieve_text_default_order(frames)
      end

      full_consensus_text
    end

    # helper function for consensus_text
    def retrieve_text_default_order(frames)
      full_consensus_text = ''

      frames.each_value do |frame|
        full_consensus_text = add_frame_to_consensus_text(frame, full_consensus_text)
      end

      full_consensus_text
    end

    # helper function for consensus_text
    def retrieve_text_by_frame_order(frame_order, frames)
      full_consensus_text = ''

      frame_order.each do |frame_label|
        frame = frames[frame_label]
        full_consensus_text = add_frame_to_consensus_text(frame, full_consensus_text)
      end

      full_consensus_text
    end

    # helper function for consensus_text
    def add_frame_to_consensus_text(frame, full_consensus_text)
      frame.each do |line|
        line_text = if line['edited_consensus_text'].present?
                      line['edited_consensus_text']
                    else
                      line['consensus_text']
                    end

        full_consensus_text.concat line_text + "\n"
      end
      # new line after every frame
      full_consensus_text.concat "\n"
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
      csv_lines << line_metadata_csv_headers

      frame_regex = /^frame/
      frames = @transcription.text.filter { |key, _value| frame_regex.match(key) }
      if @transcription.frame_order.present?
        csv_lines = retrieve_line_data_by_frame_order(@transcription.frame_order, frames, csv_lines)
      else
        csv_lines = retrieve_line_data_by_default_order(frames, csv_lines)
      end

      csv_lines
    end

    def line_metadata_csv_headers
      [
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
        'line start x',
        'line end x',
        'line start y',
        'line end y'
      ]
    end

    def retrieve_line_data_by_default_order(frames, csv_lines)
      frames.each_with_index do |(_key, frame), page_index|
        page = page_index + 1
        csv_lines = add_frame_to_line_metadata(frame, page, csv_lines)
      end

      csv_lines
    end

    def retrieve_line_data_by_frame_order(frame_order, frames, csv_lines)
      frame_order.each_with_index do |frame_label, page_index|
        page = page_index + 1
        frame = frames[frame_label]
        csv_lines = add_frame_to_line_metadata(frame, page, csv_lines)
      end

      csv_lines
    end

    def add_frame_to_line_metadata(frame, page, csv_lines)
      # iterate through the lines of the frame
      frame.each_with_index do |line, line_index|
        line_number = line_index + 1
        column = line['gutter_label'] + 1
        num_transcribers = line['user_ids'].count
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
          line['clusters_x'][0],
          line['clusters_x'][1],
          line['clusters_y'][0],
          line['clusters_y'][1]
        ]
      end

      csv_lines
    end
  end
end
