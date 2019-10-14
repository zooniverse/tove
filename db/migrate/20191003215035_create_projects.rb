class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :slug, null: false

      t.timestamps
    end
  end
end
