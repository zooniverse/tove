require 'csv'
require 'retryable'

module DataExports
  # Helper class for aggregating metadata from individual transcriptions
  # within a group/workflow/project into a single csv file
  class AggregateMetadataFileGenerator
    class << self
      include Retryable
      # Public: add metadata csv file to group folder
      def generate_group_file(transcriptions, output_folder)
        metadata_rows = compile_transcription_metadata(transcriptions, output_folder)
        generate_csv(output_folder, metadata_rows)
      end

      # Public: add metadata csv file to workflow folder
      def generate_workflow_file(workflow, output_folder)
        metadata_rows = compile_workflow_metadata(workflow, output_folder)
        generate_csv(output_folder, metadata_rows)
      end

      def generate_project_file(project, output_folder)
        metadata_rows = []
        project.workflows.each do |w|
          metadata_rows += compile_workflow_metadata(w, output_folder)
        end

        generate_csv(output_folder, metadata_rows)
      end

      private

      # Private: for each transcription, extracts transcription metadata from metadata
      # storage file, adds it to the metadata_rows array, which will be passed to a
      # csv file generator.
      # @param metadata_rows [Array]: collection of metadata rows for the current
      # group/workflow/project being processed
      # @param output_folder [String]: the directory from which to read the metadata files
      # returns updated metadata_rows array
      def compile_transcription_metadata(transcriptions, group_folder)
        metadata_rows = []
        transcriptions.each do |transcription|
          # Assumes that all transcription metadata files exist, since this step always comes after
          # a full download and we don't want the db/storage costs of checking/downloading
          metadata_filename = "#{ group_folder }/transcription_metadata_#{ transcription.id }.csv"
          rows = CSV.read(metadata_filename)
          # add header if it's the first transcription being added
          metadata_rows << rows[0] if metadata_rows.empty?
          # add content regardless
          metadata_rows << rows[1]
        end

        metadata_rows
      end

      def compile_workflow_metadata(workflow, output_folder)
        metadata_rows = []

        workflow.transcription_group_data.each_key do |group_key|
          transcriptions = Transcription.where(group_id: group_key)
          metadata_rows += compile_transcription_metadata(transcriptions, output_folder)
        end

        metadata_rows
      end

      def generate_csv(output_folder, metadata_rows)
        metadata_file = File.join(output_folder, 'transcriptions_metadata.csv')

        CSV.open(metadata_file, 'wb') do |csv|
          metadata_rows.each { |row| csv << row }
        end
      end
    end
  end
end
