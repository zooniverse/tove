require 'json'

RSpec.describe DataExports::TranscriptionFileGenerator do
  context 'when transcription contains no edited lines' do
    describe '#generate_transcription_files' do
      let(:transcription) { create(:transcription, :unedited_json_blob) }
      let(:file_generator) { described_class.new transcription }
      let(:files) { file_generator.generate_transcription_files }

      # close out tempfiles that have been opened
      after(:each) do
        files.each do |file|
          file.close
          file.unlink
        end
      end

      it 'generates a file containing raw data' do
        raw_data_file = files.detect do |f|
          basename = File.basename(f)
          /^raw_data_.*\.json$/.match(basename)
        end

        expect(File).to exist(raw_data_file.path)
        expect(raw_data_file.read).to eq(transcription.text.to_json)
      end

      it 'generates a file containing consensus text with default frame order' do
        consensus_text_file = files.detect do |f|
          basename = File.basename(f)
          /^consensus_text_.*\.txt$/.match(basename)
        end

        expect(File).to exist(consensus_text_file.path)
        expect(consensus_text_file.read).to eq("[deletion][/deletion]\nMs Z B oakes\ntest\nJohn's Lelaud Sept 18th 1856\nMr L B oakes\nDear sir I have just received\ninformation that a fellow of mine\nMoses, a small black man who has\nbeen runaway for some months was\nlodged in the workhouse or at least\nyesterday\nhaving made up my mind to sell him\nsame\ndelay\nnot sell him\nWhat what?\n\n\nyour respectfully\n\n")
      end

      it 'generates a file containing transcription metadata with 2 rows' do
        metadata_file = files.detect do |f|
          basename = File.basename(f)
          /^transcription_metadata_.*\.csv$/.match(basename)
        end

        expect(File).to exist(metadata_file)
      end

      it 'generates transcription metadata file with expected header and number of rows' do
        metadata_file = files.detect do |f|
          basename = File.basename(f)
          /^transcription_metadata_.*\.csv$/.match(basename)
        end

        rows = CSV.parse(metadata_file.read)
        expect(rows[0]).to eq([
                                'transcription id',
                                'internal id',
                                'reducer',
                                'caesar parameters',
                                'date approved',
                                'user who approved',
                                'text edited (T/F)',
                                'number of pages'
                              ])
        expect(rows.length).to eq(2)
      end

      it 'determines that no lines were edited' do
        expect(file_generator.instance_eval { is_text_edited? }).to eq(false)
      end

      it 'generates file containing line metadata' do
        line_metadata_file = files.detect do |f|
          basename = File.basename(f)
          /^transcription_line_metadata_.*\.csv$/.match(basename)
        end

        expect(File).to exist(line_metadata_file)
      end

      it 'generates line metadata file with correct header' do
        line_metadata_file = files.detect do |f|
          basename = File.basename(f)
          /^transcription_line_metadata_.*\.csv$/.match(basename)
        end

        rows = CSV.parse(line_metadata_file.read)
        expect(rows[0]).to eq([
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
                              ])
      end
    end
  end

  context 'when transcription contains edited lines' do
    describe '#generate_transcription_files' do
      let(:transcription) { create(:transcription, :edited_json_blob) }
      let(:file_generator) { described_class.new transcription }
      let(:files) { file_generator.generate_transcription_files }

      it 'determines that lines were edited' do
        expect(file_generator.instance_eval { is_text_edited? }).to be_truthy
      end

      it 'generates a file containing consensus text' do
        consensus_text_file = files.detect do |file|
          basename = File.basename(file)
          /^consensus_text_.*\.txt$/.match(basename)
        end

        expect(File).to exist(consensus_text_file.path)

        # confirm that first line of edited consensus text is present in file
        first_consensus_line = transcription.text['frame0'][0]['edited_consensus_text']
        expect(consensus_text_file.read).to include(first_consensus_line)

        files.each do |file|
          file.close
          file.unlink
        end
      end
    end
  end

  context 'when transcription contains frame order' do
    let(:transcription) { create(:transcription, :unedited_json_blob, :frame_order_set) }
    let(:file_generator) { described_class.new transcription }
    let(:files) { file_generator.generate_transcription_files }

    it 'retrieves text by frame order' do
      expect(file_generator).to receive(:retrieve_text_by_frame_order).and_call_original

      consensus_text_file = files.detect do |f|
        basename = File.basename(f)
        /^consensus_text_.*\.txt$/.match(basename)
      end

      expect(consensus_text_file.read).to eq("\nyour respectfully\n\n[deletion][/deletion]\nMs Z B oakes\ntest\nJohn's Lelaud Sept 18th 1856\nMr L B oakes\nDear sir I have just received\ninformation that a fellow of mine\nMoses, a small black man who has\nbeen runaway for some months was\nlodged in the workhouse or at least\nyesterday\nhaving made up my mind to sell him\nsame\ndelay\nnot sell him\nWhat what?\n\n")
    end
  end
end
