class CreateGlobalIdentities < ActiveRecord::Migration
  def up
    create_table  :global_identities,
      {
        :id           => false,
        :primary_key  => :ulid
      } do |t|
        t.string :ulid, index: { unique: true }
      end

    if schema_search_path == "\"public\""
      execute <<-SQL.squish
        insert into public.global_identities select * from public.global_identity_tmp;
      SQL
    end
  end

  def down
    create_table :global_identity_tmp, force: :cascade do |t|
      t.binary :ulid, limit: 16
      t.string :ngo_name
      t.integer :client_id
    end

    if schema_search_path == "\"public\""
      execute <<-SQL.squish
        insert into public.global_identity_tmp select * from public.global_identities;
      SQL
    end
    drop_table :global_identities, force: :cascade
  end
end
