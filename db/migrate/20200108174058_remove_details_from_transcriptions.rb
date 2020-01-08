class RemoveDetailsFromTranscriptions < ActiveRecord::Migration[6.0]
  def change

    remove_column :transcriptions, :updated_by, :string

    remove_column :transcriptions, :total_lines, :integer

    remove_column :transcriptions, :total_pages, :integer
  end
end
