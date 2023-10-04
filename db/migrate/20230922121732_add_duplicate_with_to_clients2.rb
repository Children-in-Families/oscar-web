class AddDuplicateWithToClients2 < ActiveRecord::Migration
  def change
    remove_column :clients, :duplicate, :boolean, default: false if column_exists?(:clients, :duplicate)
    remove_column :clients, :duplicate_with, :jsonb, default: {} if column_exists?(:clients, :duplicate_with)

    add_column :shared_clients, :ngo_name, :string
    add_column :shared_clients, :client_created_at, :datetime

    add_column :shared_clients, :duplicate, :boolean, default: false
    add_column :shared_clients, :duplicate_with, :jsonb, default: {}
  end
end
