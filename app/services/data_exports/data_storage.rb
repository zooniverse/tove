require 'fileutils'
require 'securerandom'
require 'retryable'

module DataExports
  class DataStorage
    include Retryable

    class NoStoredFilesFoundError < StandardError; end

    # Public: downloads all transcription files for a given transcription
    # returns path to zip file
    def zip_transcription_files(transcription)
      if transcription.export_files.attached?
        Dir.mktmpdir do |directory_path|
          transcription_folder = download_transcription_files(transcription, directory_path, single_transcription_export: true)
          yield zip_files(directory_path, transcription_folder)
        end
      else
        raise NoStoredFilesFoundError.new("No stored files found for transcription id '#{transcription.id}'")
      end
    end

    # Public : downloads all transcription group files for a given group
    # returns path to zip file
    def zip_group_files(transcriptions)
      Dir.mktmpdir do |directory_path|
        group_folder = File.join(directory_path, "group_#{transcriptions.first.group_id}")
        FileUtils.mkdir_p(group_folder)

        transcriptions.each do |transcription|
          download_transcription_files(transcription, group_folder) if transcription.export_files.attached?
        end

        AggregateMetadataFileGenerator.generate_group_file(transcriptions, group_folder)

        yield zip_files(directory_path, group_folder)
      end
    end

    # Extremely hacky workaround for getting a group's worth of transcriptions out at a time.
    # Use this on the console to save a transcription group export locally, then kubectl cp them out of the pod directly.
    # This also (optionally) regens the files if the transcription is approved.
    # Regenning files is heavy and could cause issues on large sets, be careful.
    # This'll go away very soon but will buy some time.
    def save_transcription_files_locally(transcriptions, regen: false)
      group_id = transcriptions.first.group_id
      workflow_id = transcriptions.first.workflow_id
      directory_path = "/tmp/saved/"

      group_folder = File.join(directory_path, "wf_#{ workflow_id }_group_#{ group_id }")
      FileUtils.mkdir_p(group_folder)

      transcriptions.each do |transcription|
        transcription.upload_files_to_storage if regen && transcription.approved?
        download_transcription_files(transcription, group_folder) if transcription.export_files.attached?
      end

      AggregateMetadataFileGenerator.generate_group_file(transcriptions, group_folder)

      zip_file_path = File.join(directory_path, "wf_#{ workflow_id }_group_#{ group_id }_export.zip")
      zip_generator = ZipFileGenerator.new(group_folder, zip_file_path)
      zip_generator.write
    end

    # Public : downloads all files for a given workflow
    # returns path to zip file
    def zip_workflow_files(workflow)
      Dir.mktmpdir do |directory_path|
        workflow_folder = download_workflow_files(workflow, directory_path)
        AggregateMetadataFileGenerator.generate_workflow_file(workflow, workflow_folder)

        yield zip_files(directory_path, workflow_folder)
      end
    end

    # Public : downloads all files for a given project
    # returns path to zip file
    def zip_project_files(project)
      Dir.mktmpdir do |directory_path|
        project_folder = File.join(directory_path, "project_#{project.id}")
        FileUtils.mkdir_p(project_folder)

        project.workflows.each do |w|
          download_workflow_files(w, project_folder)
        end

        AggregateMetadataFileGenerator.generate_project_file(project, project_folder)

        yield zip_files(directory_path, project_folder)
      end
    end

    private

    # download transcription files for a given transcription from storage to disk
    # @param transcription [Transcription]: the transcription we want to retrieve files for
    # @param directory_path [String]: path within which we will create the transcription file folder
    # returns location of generated transcription folder
    def download_transcription_files(transcription, directory_path, single_transcription_export: false)
      transcription_folder = File.join(directory_path, "transcription_#{transcription.id}")
      FileUtils.mkdir_p(transcription_folder)

      metadata_file_regex = /^transcription_metadata_.*\.csv$/
      transcription.export_files.each do |storage_file|
        download_file_from_storage(storage_file, transcription_folder)
      end

      transcription_folder
    end

    # download a single transcription file from storage to disk
    # helper method for `download_transcription_files`
    def download_file_from_storage(storage_file, transcription_folder)
      download_path = File.join(transcription_folder, storage_file.filename.to_s)
      file = File.open(download_path, 'w')
      begin
        with_retries(
          rescue_class: [Faraday::ConnectionFailed, Faraday::TimeoutError, Errno::ECONNREFUSED]
        ) { file.write(storage_file.download.force_encoding('UTF-8')) }
      rescue Encoding::UndefinedConversionError => exception
        # build new exception with message including the problematic file
        message = exception.message + ". Filename: #{storage_file.filename}, Blob path: #{storage_file.key}, Blob id: #{storage_file.blob_id}"
        raise Encoding::UndefinedConversionError.new(message)
      ensure
        file.close
      end
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
      zip_file_path = File.join(output_directory, "export.zip")
      zip_generator = ZipFileGenerator.new(input_directory, zip_file_path)
      zip_generator.write

      FileUtils.rm_rf(input_directory)

      zip_file_path
    end
  end
end
