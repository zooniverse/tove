class CreateTranscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :transcriptions do |t|
      t.integer :subject_id, null: false
      t.integer :workflow_id, null: false
      t.string :group_id, null: false
      t.jsonb :text, null: false
      t.integer :status, null: false
      t.boolean :flagged, null: false, default: false

      t.timestamps
    end
  end
end
