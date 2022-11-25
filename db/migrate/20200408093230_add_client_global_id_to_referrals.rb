class AddClientGlobalIdToReferrals < ActiveRecord::Migration[5.2]
  def up
    add_column :referrals, :client_global_id, :integer unless column_exists?(:referrals, :client_global_id)

    change_column :referrals, :client_global_id, :string if Referral.columns_hash["client_global_id"].type == :integer
    add_index :referrals, :client_global_id if !index_exists?(:referrals, :client_global_id)

    if schema_search_path == "\"mrs\"" && table_exists?(:global_identity_tmp)
      if column_exists?(:referrals, :client_global_id)
        execute <<-SQL.squish
          UPDATE referrals AS r SET client_global_id = encode(g.ulid, 'escape') FROM public.global_identity_tmp AS g WHERE CAST(g.id as varchar) = r.client_global_id;
        SQL
      end
    end
  end

  def down
    remove_index :referrals, :client_global_id if index_exists?(:referrals, :client_global_id)
  end
end
