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

  def put_file(storage_path, file)
    content = ::File.open(file, 'rb') { |file| file.read }
    @blob_client.create_block_blob(@container_name, storage_path, content)
  end

  # receive a list of hashes formatted as
  # { storage_path: <path_to_blob>, file: <file_name> }
  def put_files_multiple(file_list)
    file_list.each do |f|
      put_file(f[:storage_path], f[:file])
    end
  end

  def get_file(path)
    blob, content = client.get_blob(@container_name, path)
    content
  end

  def delete_file(storage_path)
    client.delete_blob(@container_name, storage_path)
  end

  def get_filename_list(prefix)
    list = client.list_blobs(@container_name, prefix: prefix)
                 .map { |b| b.name }
  end
end
