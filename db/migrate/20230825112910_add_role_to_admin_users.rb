class AddRoleToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :role, :string, default: 'viewer'
    AdminUser.update_all(role: 'admin')
  end
end
