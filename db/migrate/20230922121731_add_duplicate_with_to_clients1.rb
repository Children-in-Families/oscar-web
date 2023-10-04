class AddDuplicateWithToClients1 < ActiveRecord::Migration
  def change
    add_column :clients, :duplicate, :boolean, default: false unless column_exists?(:clients, :duplicate)
    add_column :clients, :duplicate_with, :jsonb, default: {} unless column_exists?(:clients, :duplicate_with)
  end
end
