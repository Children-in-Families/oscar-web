class AddTokenToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :token, :string
  end
end
