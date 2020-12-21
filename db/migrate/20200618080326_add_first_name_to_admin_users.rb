class AddFirstNameToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :first_name, :string
    add_column :admin_users, :last_name, :string
  end
end
