require 'tempfile'

module DataExports
  class TranscriptionFileGenerator
    def generate_transcription_files(transcription_id)
      @transcription = Transcription.find(transcription_id)

      # really wanted to do this using the Tempfile class, but it didn't work
      # when I passed the tempfile to azure
      # raw_transcription_file = Tempfile.new([transcription_id.to_s, '.json'])
      # raw_transcription_file.write(transcription.text)

      directory_path = File.expand_path('~/Documents/temp')
      filename = File.join(path,'/t.json')

      File.open(filename, 'w') { |f|
        f.puts transcription.text
      }

      raw_transcription_file_path = File.join(generate_path(transcription), 'raw-transcription-data.json')
      azure = AzureBlobStorage.new
      azure.put_file(raw_transcription_file_path, filename)

      # raw_transcription_file.unlink
    end

    def raw_transcription_file(directory_path)
      file_path = File.join(path, "raw_data_#{@transcription.id}.json")
      
      File.open(file_path, 'w') { |f|
        f.puts @transcription.text
      }
      file_path
    end

    def generate_path(transcription)
      workflow_id = transcription.workflow_id
      project_id = Workflow.find(workflow_id).project_id

      "approved-transcriptions/#{project_id}/#{workflow_id}/#{transcription.group_id}/#{transcription.id}"
    end
  end
end
