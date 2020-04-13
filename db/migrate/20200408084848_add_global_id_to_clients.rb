class AddGlobalIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :global_id, :integer
    add_foreign_key :clients, "public.global_identities", column: :global_id
    add_index :clients, :global_id
  end
end
