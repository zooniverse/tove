module ActiveStorageHelper
  # ported from https://github.com/rails/rails/blob/6-0-stable/activestorage/test/test_helper.rb
  def create_file_blob(filename: "transcription_file.txt", content_type: "text/plain", metadata: nil, record: nil)
    ActiveStorage::Blob.create_and_upload! io: file_fixture(filename).open, filename: filename, content_type: content_type, metadata: metadata, record: record
  end
end

RSpec.configure do |config|
  config.include ActiveStorageHelper
end