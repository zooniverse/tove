require 'csv'

module DataExports
  # Helper class for aggregating metadata from individual transcriptions
  # within a group/workflow/project into a single csv file
  class AggregateMetadataFileGenerator
    class << self
      # Public: add metadata csv file to group folder
      def generate_group_file(transcriptions, output_folder)
        @metadata_file = File.join(output_folder, 'transcriptions_metadata.csv')

        compile_transcription_metadata(transcriptions)
        generate_csv
      end

      # Public: add metadata csv file to workflow folder
      def generate_workflow_file(workflow, output_folder)
        @metadata_file = File.join(output_folder, 'transcriptions_metadata.csv')

        compile_workflow_metadata(workflow)
        generate_csv
      end

      def generate_project_file(project, output_folder)
        @metadata_file = File.join(output_folder, 'transcriptions_metadata.csv')

        project.workflows.each do |w|
          compile_workflow_metadata(w)
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
        @metadata_rows = []
        metadata_file_regex = /^transcription_metadata_.*\.csv$/

        transcriptions.each do |transcription|
          transcription.files.each do |storage_file|
            is_transcription_metadata_file = metadata_file_regex.match storage_file.filename.to_s
            if is_transcription_metadata_file
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
        @metadata_rows = []

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
  end
end
