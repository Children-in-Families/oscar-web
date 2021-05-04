class CreateClientStoreProcedure < ActiveRecord::Migration
  def up
    if schema_search_path =~ /^\"public\"/
      execute <<-SQL.squish
        CREATE OR REPLACE FUNCTION "sp_ratanak_clients"()
        RETURNS SETOF refcursor AS
        $BODY$
        DECLARE
          client_records refcursor := 'clients_cursor';
          user_records refcursor := 'users_cursor';
        BEGIN
        open client_records FOR
        SELECT * FROM ratanak.clients;
        RETURN NEXT client_records;

        open user_records FOR
        SELECT * FROM ratanak.users;
        RETURN NEXT user_records;
        RETURN;
        END;$BODY$
        LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER;
        GRANT EXECUTE ON FUNCTION "sp_ratanak_clients"() TO "#{ENV['POWER_BI_GROUP']}";
      SQL
    end
  end

  def down
    if schema_search_path =~ /^\"public\"/
      execute <<-SQL.squish
        -- DROP INDEX IF EXISTS index_donors_on_global_id CASCADE;
        -- ALTER TABLE donors DROP COLUMN IF EXISTS global_id;

        REVOKE CONNECT ON DATABASE "#{ENV['DATABASE_NAME']}" FROM "#{ENV['POWER_BI_GROUP']}";
        REVOKE USAGE ON SCHEMA public FROM "#{ENV['POWER_BI_GROUP']}";

        REVOKE EXECUTE ON FUNCTION "public"."sp_ratanak_clients"() FROM "#{ENV['POWER_BI_GROUP']}";
        DROP FUNCTION IF EXISTS "public"."sp_ratanak_clients"() CASCADE;
      SQL
    end
  end
end
