module Adapters
  class AzureAdapter
    def initialize
      # login
      blob_client = Azure::Storage::Blob::BlobService.create(
        storage_account_name: Rails.application.credentials.storage_account_name,
        storage_access_key: Rails.application.credentials.storage_access_key
      )
    end
  end
end
