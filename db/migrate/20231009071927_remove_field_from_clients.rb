class RemoveFieldFromClients < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        remove_column :clients, :duplicate if column_exists? :clients, :duplicate
        remove_column :clients, :duplicate_with if column_exists? :clients, :duplicate_with
      end
    end
  end
end
