class DropSubjectsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :subjects
  end
end
