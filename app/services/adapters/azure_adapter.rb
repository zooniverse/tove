module Adapters
  class AzureAdapter
    def initialize
      # login
      blob_client = Azure::Storage::Blob::BlobService.create(
        storage_account_name: Rails.application.credentials.storage_account_name,
        storage_access_key: Rails.application.credentials.storage_access_key
      )
    end

    def put_file
      # to do
    end

    def get_file
      # to do
    end

    def delete_file
      # to do
    end

    def get_project_files(project_id)
      # to do
    end

    def get_workflow_files(workflow_id)
      # to do
    end
  end
end
