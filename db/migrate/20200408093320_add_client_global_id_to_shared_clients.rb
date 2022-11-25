class AddClientGlobalIdToSharedClients < ActiveRecord::Migration[5.2]
  def up
    add_column :shared_clients, :global_id, :string unless column_exists?(:shared_clients, :global_id)
    change_column :shared_clients, :global_id, :string
    add_index :shared_clients, :global_id if !index_exists?(:shared_clients, :global_id)

    if schema_search_path == "\"shared\"" && column_exists?(:shared_clients, :global_id) && table_exists?(:global_identity_tmp)
      execute <<-SQL.squish
        UPDATE shared_clients AS sc SET global_id = encode(g.ulid, 'escape') FROM public.global_identity_tmp AS g WHERE CAST(g.id as varchar) = sc.global_id;
      SQL
    end
  end

  def down
    # change_column :shared_clients, :global_id, :integer, using: 'global_id::integer'
    add_index :shared_clients, :global_id if !index_exists?(:shared_clients, :global_id)
  end
end
