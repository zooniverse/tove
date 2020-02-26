class AddIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :transcriptions, :group_id
    add_index :transcriptions, :workflow_id
    add_index :transcriptions, :updated_by
    add_index :workflows, :project_id
  end
end
