class AddColumnsToTranscription < ActiveRecord::Migration[6.0]
  def change
    add_column :transcriptions, :locked_by, :string
    add_column :transcriptions, :lock_timeout, :datetime
  end
end
