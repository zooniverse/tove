class AddRolesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :roles, :jsonb
    add_column :users, :roles_refreshed_at, :datetime

    add_column :users, :display_name, :string
    add_column :users, :admin, :boolean, null: false, default: false
  end
end
