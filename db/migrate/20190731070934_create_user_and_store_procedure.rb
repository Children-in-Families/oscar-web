class CreateUserAndStoreProcedure < ActiveRecord::Migration
  def up
    if schema_search_path == "\"public\""
      execute <<-SQL.squish
        CREATE ROLE "#{ENV['READ_ONLY_DATABASE_USER']}" WITH LOGIN PASSWORD '#{ENV['READ_ONLY_DATABASE_PASSWORD']}' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION VALID UNTIL 'infinity';
        GRANT CONNECT ON DATABASE "#{ENV['DATABASE_NAME']}" TO "#{ENV['READ_ONLY_DATABASE_USER']}";
        GRANT USAGE ON SCHEMA public TO "#{ENV['READ_ONLY_DATABASE_USER']}";
        GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO "#{ENV['READ_ONLY_DATABASE_USER']}";
        CREATE OR REPLACE FUNCTION "public"."hello_world"()
        RETURNS "pg_catalog"."text"
        AS $$
        BEGIN
          RETURN 'Hello World';
        END;
        $$ LANGUAGE plpgsql VOLATILE COST 100;
      SQL
    end
  end

  def down
    if schema_search_path == "\"public\""
      execute <<-SQL.squish
        REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM "#{ENV['READ_ONLY_DATABASE_USER']}";
        REVOKE CONNECT ON DATABASE "#{ENV['DATABASE_NAME']}" FROM "#{ENV['READ_ONLY_DATABASE_USER']}";
        REVOKE USAGE ON SCHEMA public FROM "#{ENV['READ_ONLY_DATABASE_USER']}";
        DROP USER IF EXISTS "#{ENV['READ_ONLY_DATABASE_USER']}";
        DROP FUNCTION IF EXISTS "public"."hello_world"() CASCADE;
      SQL
    end
  end
end
