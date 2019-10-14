class CreateSubjects < ActiveRecord::Migration[6.0]
  def change
    create_table :subjects do |t|
      t.integer :workflow_id, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end
  end
end
