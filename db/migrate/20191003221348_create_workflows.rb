class CreateWorkflows < ActiveRecord::Migration[6.0]
  def change
    create_table :workflows do |t|
      t.integer :project_id, null: false
      t.string :display_name, null: false

      t.timestamps
    end
  end
end
