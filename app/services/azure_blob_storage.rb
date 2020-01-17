require 'azure/storage/blob'

class AzureBlobStorage
  def initialize
    # login
    @blob_client = Azure::Storage::Blob::BlobService.create(
      storage_account_name: Rails.application.credentials.storage_account_name,
      storage_access_key: Rails.application.credentials.storage_access_key
    )

    # this is equivalent to S3 bucket, where have we stored bucket names
    # in the past? I dont wanna keep it here, hardcoded.
    # maybe put in the rails credentials file...? not sure.
    @container_name = 'data-exports'
  end

  def put_file(path, file)
    binding.pry
    @blob_client.create_block_blob(@container_name, path, file)
  end

  def get_file(path)
    # to do
  end

  def delete_file
    # to do
  end

  def get_files(prefix)
    # to do
  end
end
