class CreateRatanakDatabaseUser < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            DO
            $do$
            BEGIN
               IF NOT EXISTS (
                  SELECT FROM pg_catalog.pg_roles
                  WHERE rolname = '#{ENV['READ_ONLY_RATANAK_DATABASE_USER']}') THEN
                  CREATE ROLE "#{ENV['POWER_BI_GROUP']}" WITH LOGIN ENCRYPTED PASSWORD '#{ENV['READ_ONLY_RATANAK_DATABASE_PASSWORD']}';
                  CREATE ROLE "#{ENV['READ_ONLY_RATANAK_DATABASE_USER']}" WITH LOGIN ENCRYPTED PASSWORD '#{ENV['READ_ONLY_RATANAK_DATABASE_PASSWORD']}' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION VALID UNTIL 'infinity';
                  GRANT "#{ENV['POWER_BI_GROUP']}" TO "#{ENV['READ_ONLY_RATANAK_DATABASE_USER']}";
               END IF;
            END
            $do$;

            GRANT CONNECT ON DATABASE "#{ENV['DATABASE_NAME']}" TO "#{ENV['POWER_BI_GROUP']}";
            GRANT USAGE ON SCHEMA public TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE CONNECT ON DATABASE "#{ENV['DATABASE_NAME']}" FROM "#{ENV['POWER_BI_GROUP']}";
            REVOKE USAGE ON SCHEMA public FROM "#{ENV['POWER_BI_GROUP']}";
            -- DROP OWNED BY "#{ENV['POWER_BI_GROUP']}";
            -- DROP ROLE IF EXISTS "#{ENV['POWER_BI_GROUP']}";
            -- DROP USER IF EXISTS "#{ENV['READ_ONLY_DATABASE_USER']}";
          SQL
        end
      end
    end
  end
end
