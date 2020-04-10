module DataExports
  module LineMetadataFileGenerator
    private

    # creates transcription line metadata file,
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

    # retrieve and return transcription line metadata formatted as
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
