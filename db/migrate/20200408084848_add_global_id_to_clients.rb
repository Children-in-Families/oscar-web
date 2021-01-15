class AddGlobalIdToClients < ActiveRecord::Migration
  def up
    add_column :clients, :global_id, :string unless column_exists?(:clients, :global_id)
    change_column :clients, :global_id, :string
    add_index :clients, :global_id if !index_exists?(:clients, :global_id)

    if table_exists?(:global_identity_tmp)
      execute <<-SQL.squish
        UPDATE clients AS c SET global_id = encode(g.ulid, 'escape') FROM public.global_identity_tmp AS g WHERE g.client_id = c.id AND CAST(g.id as varchar) = c.global_id;
      SQL
    end
  end

  def down
    # change_column :clients, :global_id, :integer, using: 'global_id::integer' if Client.columns_hash["global_id"].type == :string
    remove_foreign_key :clients, column: :global_id if foreign_keys(:clients).map(&:column).include?("global_id")
  end
end
