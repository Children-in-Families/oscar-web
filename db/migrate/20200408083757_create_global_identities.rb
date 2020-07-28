class CreateGlobalIdentities < ActiveRecord::Migration
  def up
    # drop_table :global_identities, force: :cascade if table_exists? :global_identities

    if !table_exists? :global_identities
      create_table  :global_identities,
        {
          :id           => false,
          :primary_key  => :ulid
        } do |t|
          t.string :ulid, index: { unique: true }
        end
    end

    # if schema_search_path =~ /^\"public\"/
    #   execute <<-SQL.squish
    #     insert into public.global_identities select encode(public.global_identity_tmp.ulid, 'escape') ulid from public.global_identity_tmp;
    #   SQL
    # end
  end

  def down
    # if !table_exists? :global_identity_tmp
    #   create_table :global_identity_tmp, force: :cascade do |t|
    #     t.binary :ulid, limit: 16
    #     t.string :ngo_name
    #     t.integer :client_id
    #   end

    #   execute <<-SQL.squish
    #     insert into public.global_identity_tmp (SELECT public.global_identities.id, public.global_identities.ulid, CAST(#{schema_search_path.gsub('"', '\'')} as varchar) ngo_name, clients.id client_id from public.global_identities INNER JOIN clients ON clients.global_id = public.global_identities.id WHERE NOT EXISTS (SELECT public.global_identity_tmp.id FROM public.global_identity_tmp WHERE public.global_identity_tmp.id = public.global_identities.id));
    #   SQL
    # end
    # drop_table :global_identities, force: :cascade
  end
end
