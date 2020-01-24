require 'fileutils'
require 'securerandom'
require 'csv'

module DataExports

  class DataStorage
    # this method is called when a transcription is set to status approved
    def export_transcription(transcription_id)
      file_generator = TranscriptionFileGenerator.new(transcription_id)
      file_list = file_generator.generate_transcription_files

      azure = AzureBlobStorage.new
      azure.put_files_multiple(file_list)

      # we are done with the files, delete the temp directory and its contents
      file_generator.delete_temp_directory
    end

    # this method is called when transcription status changes from approved to
    # any other status
    def delete_stored_transcription_data(transcription_id)
      # to do
      # prefix = transcription_storage_directory()
    end

    def self.transcription_storage_directory(transcription)
      workflow_id = transcription.workflow_id
      project_id = Workflow.find(workflow_id).project_id

      "approved-transcriptions/#{project_id}/#{workflow_id}/#{transcription.group_id}/#{transcription.id}"
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
      storage_directory = DataStorage.transcription_storage_directory(@transcription)

      # raw data file
      file_path = write_raw_data_to_file
      storage_path = File.join(storage_directory, "raw_data_#{@transcription.id}.json")
      file_list.append({ :storage_path => storage_path, :file => file_path })

      # consensus text file
      file_path = write_consensus_text_to_file
      storage_path = File.join(storage_directory, "consensus_text_#{@transcription.id}.txt")
      file_list.append({ :storage_path => storage_path, :file => file_path })

      # transcription metadata file
      file_path = write_metadata_to_file
      storage_path = File.join(storage_directory, "transcription_metadata_#{@transcription.id}.csv")
      file_list.append({ :storage_path => storage_path, :file => file_path })


      # transcription line metadata file
      file_path = write_line_metadata_to_file
      storage_path = File.join(storage_directory, "transcription_line_metadata_#{@transcription.id}.csv")
      file_list.append({ :storage_path => storage_path, :file => file_path })
    end

    def delete_temp_directory
      FileUtils.remove_dir(@directory_path)
    end

    private

    # creates raw data file
    # returns location of the file
    def write_raw_data_to_file
      file_path = File.join(@directory_path, "raw_data_#{@transcription.id}.json")

      File.open(file_path, 'w') { |f|
        f.puts @transcription.text
      }
      file_path
    end

    # creates raw data file
    # returns location of the file
    def write_consensus_text_to_file
      file_path = File.join(@directory_path, "consensus_text_#{@transcription.id}.txt")

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

    def write_metadata_to_file
      file_path = File.join(@directory_path, "transcription_metadata_#{@transcription.id}.csv")
      CSV.open(file_path, 'wb') do |csv|
        transcription_metadata.each do |csv_line|
          csv << csv_line
        end
      end

      file_path
    end

    def write_line_metadata_to_file
      file_path = File.join(@directory_path, "transcription_line_metadata_#{@transcription.id}.csv")
      CSV.open(file_path, 'wb') do |csv|
        transcription_line_metadata.each do |csv_line|
          csv << csv_line
        end
      end

      file_path
    end

    def transcription_metadata
      # still to get:
      #   * external id
      #   * caesar parameters
      #   * aggregation algorithm
      #   * text edited (based on if a line was edited)

      csv_lines = []
      csv_lines << [
        'transcription id',
        'external id',
        'caesar parameters',
        'aggregation algorithm',
        'date approved',
        'user who approved',
        'text edited (T/F)',
        'number of pages'
      ]
      csv_lines << [
        @transcription.id,
        'external id',
        'caesar parameters',
        'aggregation algorithm',
        @transcription.updated_at,
        @transcription.updated_by,
        'text edited (T/F)',
        @transcription.total_pages
      ]
    end

    def transcription_line_metadata
      # still to get:
      #   * line edited
      #   * orig transcriber username
      #   * line editor username

      csv_lines = []
      csv_lines << [
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
      ]

      @transcription.text.each_with_index do |(key, value), page_index|
        # if we find a frame, iterate through the lines of the frame
        if /^frame/.match(key)
          page = page_index + 1

          value.each_with_index do |line, line_index|
            line_number = line_index + 1
            column = line['gutter_label'] + 1
            num_transcribers = line['user_ids'].count
            line_coordinates = {
              'clusters_x': line['clusters_x'],
              'clusters_y': line['clusters_y']
            }

            csv_lines << [
              line['consensus_text'],
              line_number,
              line['line_slope'],
              line['consensus_score'],
              'line edited (T/F)',
              'original transcriber username',
              'line editor username',
              line['low_consensus'],
              page,
              column,
              num_transcribers,
              line_coordinates
            ]

            csv_lines
          end
        end
      end
    end
  end

end
