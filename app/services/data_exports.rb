require 'fileutils'
require 'securerandom'

module DataExports

  class DataExporter
    def export_transcription(transcription_id)
      file_generator = TranscriptionFileGenerator.new(transcription_id)
      file_list = file_generator.generate_transcription_files

      azure = AzureBlobStorage.new
      azure.put_files_multiple(file_list)

      # we are done with the files, delete the temp directory and its contents
      file_generator.delete_temp_directory
    end
  end

  class TranscriptionFileGenerator
    def initialize(transcription_id)
      @transcription = Transcription.find(transcription_id)
      @directory_path = File.expand_path("~/transcription_files_temp/t#{transcription_id}_#{SecureRandom.uuid}")

      FileUtils.mkdir_p @directory_path
    end

    def generate_transcription_files
      file_list = []
      blob_directory = generate_blob_directory(@transcription)

      # raw data file
      file_path = write_raw_data_to_file(@directory_path)
      blob_path = File.join(blob_directory, "raw_data_#{@transcription.id}.json")
      file_list.append({ :blob_path => blob_path, :file => file_path})

      # consensus text file
      file_path = write_consensus_text_to_file(@directory_path)
      blob_path = File.join(blob_directory, "consensus_text_#{@transcription.id}.txt")
      file_list.append({ :blob_path => blob_path, :file => file_path})
    end

    def delete_temp_directory
      FileUtils.remove_dir(@directory_path)
    end

    private

    # creates raw data file
    # returns location of the file
    def write_raw_data_to_file(directory_path)
      file_path = File.join(directory_path, "raw_data_#{@transcription.id}.json")
      
      File.open(file_path, 'w') { |f|
        f.puts @transcription.text
      }
      file_path
    end

    # creates raw data file
    # returns location of the file
    def write_consensus_text_to_file(directory_path)
      file_path = File.join(directory_path, "consensus_text_#{@transcription.id}.txt")

      File.open(file_path, 'w') { |f|
        f.puts consensus_text
      }

      file_path
    end

    def consensus_text
      consensus_text = ""
      @transcription.text.each do |key, value|
        # if we find a frame, iterate through the lines of the frame
        if /^frame/.match(key)
          value.each do |line|
            puts line["consensus_text"]
            consensus_text.concat "#{line["consensus_text"]} "
          end
        end
      end

      consensus_text
    end

    def generate_blob_directory(transcription)
      workflow_id = transcription.workflow_id
      project_id = Workflow.find(workflow_id).project_id

      "approved-transcriptions/#{project_id}/#{workflow_id}/#{transcription.group_id}/#{transcription.id}"
    end
  end

end
