class AddDetailsToTranscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :transcriptions, :total_lines, :integer
    add_column :transcriptions, :total_pages, :integer
  end
end
