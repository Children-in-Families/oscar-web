class DeviseTokenAuthCreateAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :provider, :string, null: false, default: 'email'
    add_column :admin_users, :uid, :string, null: false, default: ''
    add_column :admin_users, :tokens, :json

    reversible do |dir|
      dir.up do
        add_index :admin_users, [:uid, :provider], unique: true if !index_exists?(:admin_users, [:uid, :provider])
      end

      dir.down do
        remove_index :admin_users, [:uid, :provider] if index_exists?(:admin_users, [:uid, :provider])
      end
    end
  end
end
