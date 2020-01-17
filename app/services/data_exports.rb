require 'tempfile'

module DataExports
  class TranscriptionFileGenerator
    def generate_transcription_files(transcription_id)
      transcription = Transcription.find(transcription_id)

      raw_transcription_file = Tempfile.new([transcription_id.to_s, '.json'])
      raw_transcription_file.write(transcription.text)

      raw_transcription_file_path = File.join(generate_path(transcription), 'raw-transcription-data.json')
      azure = AzureBlobStorage.new
      azure.put_file(raw_transcription_file_path, raw_transcription_file)

      raw_transcription_file.unlink
    end

    def generate_path(transcription)
      workflow_id = transcription.workflow_id
      project_id = Workflow.find(workflow_id).project_id

      "approved-transcriptions/#{project_id}/#{workflow_id}/#{transcription.group_id}/#{transcription.id}"
    end
  end
end
