class CreateClientStoreProcedure < ActiveRecord::Migration
  def up
    if schema_search_path =~ /^\"public\"/
      execute <<-SQL.squish
        CREATE OR REPLACE PROCEDURE "public"."sp_ratanak_clients"(result_data inout refcursor) LANGUAGE plpgsql SECURITY DEFINER
        AS $BODY$
        begin
          open result_data for select * from ratanak.clients;
        end;
        $BODY$;
        GRANT EXECUTE ON PROCEDURE "public"."sp_ratanak_clients"() TO "#{ENV['POWER_BI_GROUP']}";
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

        REVOKE EXECUTE ON PROCEDURE "public"."sp_ratanak_clients"() FROM "#{ENV['POWER_BI_GROUP']}";
        DROP PROCEDURE IF EXISTS "public"."sp_ratanak_clients"() CASCADE;
      SQL
    end
  end
end
