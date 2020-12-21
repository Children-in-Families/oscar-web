class FnOscarDashboardSharedProvinces < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_shared_provinces"()
              RETURNS TABLE("id" int4, "organization_name" varchar, "name" varchar, "country" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sp_r record;
              BEGIN
                sql := sql || format(
                                'SELECT %2$s.id, %1$L organization_name,
                                %2$s.name, %2$s.country FROM %1$I.%2$s', 'shared', 'provinces');

                FOR sp_r IN EXECUTE sql
                LOOP
                  id := sp_r.id;
                  organization_name := sp_r.organization_name;
                  name := sp_r.name;
                  country := sp_r.country;
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_shared_provinces"() TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_shared_provinces"() FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_shared_provinces"() CASCADE;
          SQL
        end
      end
    end
  end
end
