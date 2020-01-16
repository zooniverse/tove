module Adapters
  class AzureAdapter
    def initialize
      # login
      blob_client = Azure::Storage::Blob::BlobService.create(
        storage_account_name: Rails.application.credentials.storage_account_name,
        storage_access_key: Rails.application.credentials.storage_access_key
      )
    end

    def upload_file
      # to do
    end

    def download_file
      # to do
    end

    def delete_file
      # to do
    end

    def get_files(prefix)
      # to do
    end
  end
end
