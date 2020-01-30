class AddNewTranscriptionFields < ActiveRecord::Migration[6.0]
  def change
    add_column :transcriptions, :internal_id, :string
    add_column :transcriptions, :reducer, :string
    add_column :transcriptions, :parameters, :string
    add_column :transcriptions, :low_consensus_lines, :integer
  end
end
