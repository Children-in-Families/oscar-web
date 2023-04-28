class CreateMtpReadOnlyDatabaseUser < ActiveRecord::Migration
  def change
    if schema_exists?('mtp')
      reversible do |dir|
        dir.up do
          if schema_search_path =~ /^\"public\"/
            execute <<-SQL.squish
              DO
              $do$
              BEGIN
                IF NOT EXISTS (
                  SELECT FROM pg_catalog.pg_roles
                  WHERE rolname = '#{ENV['READ_ONLY_MTP_DATABASE_USER']}') THEN
                  CREATE ROLE "#{ENV['READ_ONLY_MTP_DATABASE_USER']}" WITH LOGIN ENCRYPTED PASSWORD '#{ENV['READ_ONLY_MTP_DATABASE_PASSWORD']}' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION VALID UNTIL 'infinity';
                  GRANT "#{ENV['POWER_BI_GROUP']}" TO "#{ENV['READ_ONLY_MTP_DATABASE_USER']}";
                END IF;
              END
              $do$;

              GRANT USAGE ON SCHEMA mtp TO "#{ENV['READ_ONLY_MTP_DATABASE_USER']}";
              GRANT SELECT ON ALL TABLES IN SCHEMA mtp TO "#{ENV['READ_ONLY_MTP_DATABASE_USER']}";
              ALTER DEFAULT PRIVILEGES IN SCHEMA mtp GRANT SELECT ON TABLES TO "#{ENV['READ_ONLY_MTP_DATABASE_USER']}";
            SQL
          end
        end

        dir.down do
          if schema_search_path =~ /^\"public\"/
            execute <<-SQL.squish
              REASSIGN OWNED BY "#{ENV['READ_ONLY_MTP_DATABASE_USER']}" TO "#{ENV['DATABASE_USER']}";
              DROP OWNED BY "#{ENV['READ_ONLY_MTP_DATABASE_USER']}";
              DROP USER IF EXISTS "#{ENV['READ_ONLY_MTP_DATABASE_USER']}";
            SQL
          end
        end
      end
    end
  end
end
