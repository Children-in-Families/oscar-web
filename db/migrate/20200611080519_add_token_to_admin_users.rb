class AddTokenToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :token, :string
  end
end
