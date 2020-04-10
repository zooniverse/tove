module DataExports
  module ConsensusTextFileGenerator
    private

    # creates consensus text file,
    # returns location of the file
    def write_consensus_text_to_file
      file = Tempfile.new(["consensus_text_#{@transcription.id}-", '.txt'])
      file.write(consensus_text)
      file.rewind

      file
    end

    # retrieves and returns consensus text
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
  end
end
