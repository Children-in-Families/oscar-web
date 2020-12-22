class AddFielToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :organization_name, :string
    add_column :users, :profile, :string
  end
end
