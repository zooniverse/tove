class AddMetadataToTranscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :transcriptions, :metadata, :jsonb
  end
end
