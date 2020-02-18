require 'json'

RSpec.describe DataExports::TranscriptionFileGenerator do
  context 'when transcription contains no edited lines' do
    describe '#generate_transcription_files' do
      let(:transcription) { create(:transcription, :unedited_json_blob) }
      let(:file_generator) { described_class.new transcription }
      let(:files) { file_generator.generate_transcription_files }

      # close out tempfiles that have been opened
      after(:each) do
        files.each { |f|
          f.close
          f.unlink
        }
      end

      it 'generates a file containing raw data' do
        raw_data_file = files.detect { |f|
          basename = File.basename(f)
          /^raw_data_.*\.json$/.match(basename)
        }

        expect(File).to exist(raw_data_file.path)
        expect(eval(raw_data_file.read)).to eq(transcription.text)
      end

      it 'generates a file containing consensus text' do
        consensus_text_file = files.detect { |f|
          basename = File.basename(f)
          /^consensus_text_.*\.txt$/.match(basename)
        }

        expect(File).to exist(consensus_text_file.path)

        # confirm that first line of consensus text is present in file
        first_consensus_line = transcription.text['frame0'][0]['consensus_text']
        expect(consensus_text_file.read).to include(first_consensus_line)
      end

      it 'generates a file containing transcription metadata with 2 rows' do
        metadata_file = files.detect { |f|
          basename = File.basename(f)
          /^transcription_metadata_.*\.csv$/.match(basename)
        }

        expect(File).to exist(metadata_file)
      end

      it 'generates transcription metadata file with expected header and number of rows' do
        metadata_file = files.detect { |f|
          basename = File.basename(f)
          /^transcription_metadata_.*\.csv$/.match(basename)
        }

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
        expect(file_generator.instance_eval{ is_text_edited? }).to eq(false)
      end

      it 'generates file containing line metadata' do
        line_metadata_file = files.detect { |f|
          basename = File.basename(f)
          /^transcription_line_metadata_.*\.csv$/.match(basename)
        }

        expect(File).to exist(line_metadata_file)
      end

      it 'generates line metadata file with correct header' do
        line_metadata_file = files.detect { |f|
          basename = File.basename(f)
          /^transcription_line_metadata_.*\.csv$/.match(basename)
        }

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
          'line coordinates'
        ])
      end
    end
  end

  context 'when transcription contains edited lines' do
    describe '#generate_transcription_files' do
      let(:transcription) { create(:transcription, :edited_json_blob) }
      let(:file_generator) { described_class.new transcription }

      it 'determines that lines were edited' do
        expect(file_generator.instance_eval{ is_text_edited? }).to be_truthy
      end
    end
  end

end