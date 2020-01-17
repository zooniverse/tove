require 'tempfile'

module DataExports
  class TranscriptionFileGenerator
    def generate_transcription_files(transcription_id)
      @transcription = Transcription.find(transcription_id)

      directory_path = File.expand_path('~/Documents/temp')
      file_path = write_raw_data_to_file(directory_path)

      blob_path = File.join(generate_blob_directory(transcription), "raw_data_#{transcription_id}.json")
      azure = AzureBlobStorage.new
      azure.put_file(blob_path, filename)
    end

    def write_raw_data_to_file(directory_path)
      file_path = File.join(path, "raw_data_#{@transcription.id}.json")
      
      File.open(file_path, 'w') { |f|
        f.puts @transcription.text
      }
      file_path
    end

    def generate_blob_directory(transcription)
      workflow_id = transcription.workflow_id
      project_id = Workflow.find(workflow_id).project_id

      "approved-transcriptions/#{project_id}/#{workflow_id}/#{transcription.group_id}/#{transcription.id}"
    end
  end
end
