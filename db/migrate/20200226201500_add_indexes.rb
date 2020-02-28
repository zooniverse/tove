class AddIndexes < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :transcriptions, %i[group_id workflow_id], algorithm: :concurrently
    add_index :workflows, :project_id, algorithm: :concurrently
  end
end
