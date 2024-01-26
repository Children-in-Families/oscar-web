class AddDuplicateWithToClients < ActiveRecord::Migration
  def change
    add_column :clients, :duplicate, :boolean, default: false
    add_column :clients, :duplicate_with, :jsonb, default: {}
  end
end
