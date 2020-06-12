class AddGlobalIdToClients < ActiveRecord::Migration
  def up
    add_column :clients, :global_id, :string
    add_index :clients, :global_id
  end

  def down
    remove_column :clients, :global_id
    remove_foreign_key :clients, column: :global_id if foreign_keys(:clients).map(&:column).include?("global_id")
  end
end
