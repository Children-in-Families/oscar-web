class DeviseTokenAuthCreateAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :provider, :string, null: false, default: 'email'
    add_column :admin_users, :uid, :string, null: false, default: ''
    add_column :admin_users, :tokens, :json

    add_index :admin_users, [:uid, :provider],     unique: true
  end
end
