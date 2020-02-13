require 'fileutils'
require 'securerandom'
require 'csv'

module DataExports
  class NoStoredFilesFoundError < StandardError; end

  class DataStorage
    # Public: downloads all transcription files for a given transcription
    # returns path to zip file
    def zip_transcription_files(transcription)
      directory_path = File.expand_path("~/data_exports_temp/downloaded_files/user_id_#{SecureRandom.uuid}")
      FileUtils.mkdir_p(directory_path)

      if transcription.files.attached?
        transcription_folder = download_transcription_files(transcription, directory_path)
        return zip_files(directory_path, transcription_folder)
      else
        raise NoStoredFilesFoundError.new("No stored files found for transcription with id '#{transcription.id}'")
      end
    end

    # Public : downloads all transcription group files for a given group
    # returns path to zip file
    def zip_group_files(transcriptions)
      directory_path = File.expand_path("~/data_exports_temp/downloaded_files/user_id_#{SecureRandom.uuid}")
      FileUtils.mkdir_p(directory_path)

      group_folder = File.join(directory_path, "group_#{transcriptions.first.group_id}")
      FileUtils.mkdir_p(group_folder)

      metadata_file_gen = AggregateMetadataFileGenerator.new(group_folder)
      metadata_file_gen.generate_group_file(transcriptions)

      transcriptions.each do |t|
        download_transcription_files(t, group_folder) if t.files.attached?
      end

      zip_files(directory_path, group_folder)
    end

    # Public : downloads all files for a given workflow
    # returns path to zip file
    def zip_workflow_files(workflow)
      directory_path = File.expand_path("~/data_exports_temp/downloaded_files/user_id_#{SecureRandom.uuid}")
      FileUtils.mkdir_p(directory_path)

      workflow_folder = download_workflow_files(workflow, directory_path)

      metadata_file_gen = AggregateMetadataFileGenerator.new(workflow_folder)
      metadata_file_gen.generate_workflow_file(workflow)

      zip_files(directory_path, workflow_folder)
    end

    # Public : downloads all files for a given project
    # returns path to zip file
    def zip_project_files(project)
      directory_path = File.expand_path("~/data_exports_temp/downloaded_files/user_id_#{SecureRandom.uuid}")
      FileUtils.mkdir_p(directory_path)

      project_folder = File.join(directory_path, "project_#{project.id}")
      FileUtils.mkdir_p(project_folder)

      metadata_file_gen = AggregateMetadataFileGenerator.new(project_folder)
      metadata_file_gen.generate_project_file(project)

      project.workflows.each do |w|
        download_workflow_files(w, project_folder)
      end

      zip_files(directory_path, project_folder)
    end

    private

    # download transcription files for a given transcription from storage to disk
    # @param transcription [Transcription]: the transcription we want to retrieve files for
    # @param directory_path [String]: path within which we will create the transcription file folder
    # returns location of generated transcription folder
    def download_transcription_files(transcription, directory_path)
      transcription_folder = File.join(directory_path, "transcription_#{transcription.id}")
      FileUtils.mkdir_p(transcription_folder)

      transcription.files.each do |storage_file|
        download_path = File.join(transcription_folder, storage_file.filename.to_s)
        file = File.open(download_path,  'w')
        file.write(storage_file.download)
        file.close()
      end

      transcription_folder
    end

    # download workflow's transcription files from storage to disk
    # @param directory_path [String]: path within which we will create the workflow file folder
    # returns location of generated workflow folder
    def download_workflow_files(workflow, directory_path)
      workflow_folder = File.join(directory_path, "workflow_#{workflow.id}")
      FileUtils.mkdir_p(workflow_folder)

      workflow.transcription_group_data.each_key do |group_key|
        group_folder = File.join(workflow_folder, "group_#{group_key}")
        FileUtils.mkdir_p(group_folder)

        transcriptions = Transcription.where(group_id: group_key)
        transcriptions.each do |t|
          download_transcription_files(t, group_folder)
        end
      end

      workflow_folder
    end

    # @param output_directory [String]: directory into which generated zip file will be output
    # @param input_directory [String]: directory to zip
    # returns location of zip file
    def zip_files(output_directory, input_directory)
      zip_file_path = File.join(output_directory, "export_#{SecureRandom.uuid}.zip")
      zip_generator = ZipFileGenerator.new(input_directory, zip_file_path)
      zip_generator.write

      FileUtils.rm_rf(input_directory)

      zip_file_path
    end
  end

  # Helper class for aggregating metadata from individual transcriptions
  # within a group/workflow/project into a single csv file
  class AggregateMetadataFileGenerator
    def initialize(output_folder)
      @metadata_rows = []
      @metadata_file = File.join(output_folder, 'transcriptions_metadata.csv')
    end

    # Public: add metadata csv file to group folder
    def generate_group_file(transcriptions)
      compile_transcription_metadata(transcriptions)
      generate_csv
    end

    # Public: add metadata csv file to workflow folder
    def generate_workflow_file(workflow)
      compile_workflow_metadata(workflow)
      generate_csv
    end

    def generate_project_file(project)
      project.workflows.each do |w|
        compile_workflow_metadata(workflow)
      end

      generate_csv
    end

    private

    # Private: for each transcription, extracts transcription metadata from metadata
    # storage file, adds it to the metadata_rows array, which will be passed to a
    # csv file generator.
    # @param metadata_rows [Array]: collection of metadata rows for the current
    # group/workflow/project being processed
    # returns updated metadata_rows array
    def compile_transcription_metadata(transcriptions)
      transcriptions.each do |t|
        t.files.each do |storage_file|
          if /^transcription_metadata_.*\.csv$/.match storage_file.filename.to_s
            rows = CSV.parse(storage_file.download)

            # add header if it's the first transcription being added
            @metadata_rows << rows[0] if @metadata_rows.empty?
            # add content regardless
            @metadata_rows << rows[1]
          end
        end
      end
    end

    def compile_workflow_metadata(workflow)
      workflow.transcription_group_data.each_key do |group_key|
        transcriptions = Transcription.where(group_id: group_key)
        compile_transcription_metadata(transcriptions)
      end
    end

    def generate_csv
      CSV.open(@metadata_file, 'wb') do |csv|
        @metadata_rows.each { |row| csv << row }
      end
    end
  end

  class TranscriptionFileGenerator
    def initialize(transcription)
      @transcription = transcription
    end

    def generate_transcription_files
      files = []
      files.append(write_raw_data_to_file,
                      write_consensus_text_to_file,
                      write_metadata_to_file,
                      write_line_metadata_to_file)
    end

    private

    # Private: creates raw data file as tempfile,
    # returns tempfile
    def write_raw_data_to_file
      file = Tempfile.new(["raw_data_#{@transcription.id}-", '.json'])
      file.write(@transcription.text)
      file.rewind

      file
    end

    # Private: creates consensus text file,
    # returns location of the file
    def write_consensus_text_to_file
      file = Tempfile.new(["consensus_text_#{@transcription.id}-", '.txt'])
      file.write(consensus_text)
      file.rewind

      file
    end

    # Private: retrieves and returns consensus text
    def consensus_text
      full_consensus_text = ""
      @transcription.text.each do |key, value|
        # if we find a frame, iterate through the lines of the frame
        if /^frame/.match(key)
          value.each do |line|
            line_text = line['edited_consensus_text'].present? ?
                        line['edited_consensus_text'] :
                        line['consensus_text']
            full_consensus_text.concat line_text
          end
        end
      end

      full_consensus_text
    end

    # Private: creates transcription metadata file,
    # returns location of the file
    def write_metadata_to_file
      file = Tempfile.new(["transcription_metadata_#{@transcription.id}-", '.csv'])

      CSV.open(file.path, 'wb') do |csv|
        transcription_metadata.each do |csv_line|
          csv << csv_line
        end
      end

      file.rewind
      file
    end

    # Private: creates transcription line metadata file,
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

    # Private: retrieve and return transcription metadata formatted as
    # array of csv lines
    def transcription_metadata
      csv_lines = []
      csv_lines << [
        'transcription id',
        'internal id',
        'reducer',
        'caesar parameters',
        'date approved',
        'user who approved',
        'text edited (T/F)',
        'number of pages'
      ]
      csv_lines << [
        @transcription.id,
        @transcription.internal_id,
        @transcription.reducer,
        @transcription.parameters,
        @transcription.updated_at,
        @transcription.updated_by,
        is_text_edited?,
        @transcription.total_pages
      ]
    end

    def is_text_edited?
      # iterate through each 'frame' aka 'page' of transcription
      @transcription.text.each do |key, lines|
        if /^frame/.match(key)
          # iterate through each line of the frame
          lines.each do |line|
            return true if line['edited_consensus_text'].present?
          end
        end
      end

      false
    end

    # Private: retrieve and return transcription line metadata formatted as
    # array of csv lines
    def transcription_line_metadata
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
              line_coordinates
            ]

            csv_lines
          end
        end
      end
    end
  end
end
