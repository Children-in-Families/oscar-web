class CreateToreProcedureRatanakPowerbi < ActiveRecord::Migration
  def up
    if schema_search_path =~ /^\"public\"/
      execute <<-SQL.squish
        CREATE OR REPLACE PROCEDURE sp_ratanak_powerbi(
            INOUT _message TEXT = '',
            INOUT _result_clients refcursor = 'client_results',
            INOUT _result_users refcursor = 'user_results'
          )
        LANGUAGE plpgsql
        AS
        $$
        BEGIN
            _message := 'Test message for procedure ' || _message;

          open _result_clients for
            SELECT *
            FROM ratanak.clients;

          open _result_users for
            SELECT *
            FROM ratanak.users;

        END;
        $$;
        GRANT EXECUTE ON PROCEDURE "public"."sp_ratanak_powerbi"(TEXT, INOUT refcursor, INOUT refcursor) TO "#{ENV['POWER_BI_GROUP']}";
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

        REVOKE EXECUTE ON PROCEDURE "public"."sp_ratanak_powerbi"(TEXT, INOUT refcursor, INOUT refcursor) FROM "#{ENV['POWER_BI_GROUP']}";
        DROP PROCEDURE IF EXISTS "public"."sp_ratanak_powerbi"(TEXT, INOUT refcursor, INOUT refcursor) CASCADE;
      SQL
    end
  end
end
