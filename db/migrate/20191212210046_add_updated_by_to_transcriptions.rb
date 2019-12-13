class AddUpdatedByToTranscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :transcriptions, :updated_by, :string
  end
end
