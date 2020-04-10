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

    after(:each) do
      files.each do |file|
        file.close
        file.unlink
      end
    end

    it 'retrieves text by frame order' do
      expect(file_generator).to receive(:retrieve_text_by_frame_order).and_call_original

      consensus_text_file = files.detect do |f|
        basename = File.basename(f)
        /^consensus_text_.*\.txt$/.match(basename)
      end

      expect(consensus_text_file.read).to eq("\nyour respectfully\n\n[deletion][/deletion]\nMs Z B oakes\ntest\nJohn's Lelaud Sept 18th 1856\nMr L B oakes\nDear sir I have just received\ninformation that a fellow of mine\nMoses, a small black man who has\nbeen runaway for some months was\nlodged in the workhouse or at least\nyesterday\nhaving made up my mind to sell him\nsame\ndelay\nnot sell him\nWhat what?\n\n")
    end

    it 'retrieves line metadata by frame order' do
      expect(file_generator).to receive(:retrieve_line_data_by_frame_order).and_call_original

      line_metadata_file = files.detect do |f|
        basename = File.basename(f)
        /^transcription_line_metadata_.*\.csv$/.match(basename)
      end

      expect(line_metadata_file.read).to eq("consensus text,line number,line slope,consensus score,line edited (T/F),original transcriber username,line editor username,flagged for low consensus (T/F),page number,column,number of transcribers,line start x,line end x,line start y,line end y\n\"\",1,11.518659344879472,0.0,false,,,true,1,1,2,874.9671737389912,1206.417934347478,55.59727782225781,123.14411529223378\nyour respectfully,2,-4.174735093328781e-15,1.5,false,,,true,1,1,2,921.6460722404647,1315.224450618843,265.9831649406416,265.9831649406416\n[deletion][/deletion],1,179.26252336428178,1.0,false,,,true,2,1,1,1311.1291866028707,666.5167464114833,788.11004784689,781.8516746411483\nMs Z B oakes,2,179.26252336428178,2.0,false,,,true,2,1,7,913.9868111445219,610.6879194904875,266.98410480295087,271.5937382180552\ntest,3,179.26252336428178,2.0,false,,,true,2,1,2,1181.3243243243244,860.2162162162163,222.93243243243245,228.82432432432432\nJohn's Lelaud Sept 18th 1856,4,-0.221176437611867,3.0,false,,,false,2,1,6,778.8178944102211,1384.2271593758257,138.78157983107482,128.2726430438015\nMr L B oakes,5,-0.221176437611867,5.25,false,,,false,2,1,12,608.7537704148516,1000.84140625,260.2930537695804,249.22500000000002\nDear sir I have just received,6,-0.221176437611867,3.6666666666666665,false,,,false,2,1,6,667.4541769397135,1390.6588578268288,305.36150800329324,304.03032820448317\ninformation that a fellow of mine,7,-0.221176437611867,2.3333333333333335,false,,,true,2,1,3,599.8771015810208,1389.1773296798501,346.6687695098003,349.7927641488854\n\"Moses, a small black man who has\",8,-0.221176437611867,2.857142857142857,false,,,true,2,1,3,610.1383391401181,1396.512905737758,391.8689431145336,388.5538903107793\nbeen runaway for some months was,9,-0.221176437611867,1.0,false,,,true,2,1,1,588.4872830039322,1389.1773296798501,431.47057416528503,433.9456593172971\nlodged in the workhouse or at least,10,-0.221176437611867,1.0,false,,,true,2,1,1,595.9125384599686,1391.6524148318622,474.78456432549694,477.2596494775091\nyesterday,11,-0.221176437611867,1.0,false,,,true,2,1,1,1114.2187434541593,1339.3248982901018,534.9570468158536,528.6456592970889\nhaving made up my mind to sell him,12,-0.221176437611867,1.0,false,,,true,2,1,1,604.8309959169183,1369.359666252441,601.722350434937,599.9808272678856\nsame,13,-0.221176437611867,2.0,false,,,true,2,1,2,998.5099722768056,1164.7098436042772,652.7696138327956,648.562022153619\ndelay,14,-0.221176437611867,1.0,false,,,true,2,1,1,853.6358695652174,948.4184782608695,684.1290760869565,691.5339673913044\nnot sell him,15,-0.221176437611867,2.0,false,,,true,2,1,2,871.3144654088051,1139.8155136268344,736.6572327044025,730.9444444444445\nWhat what?,16,-173.9909940425054,1.0,false,,,true,2,1,1,1373.712918660287,1254.8038277511962,653.555023923445,641.0382775119617\n")
    end
  end
end
