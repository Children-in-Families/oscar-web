class FnOscarDashboardDistricts < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_districts"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "province_id" int4, "name" varchar, "code" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                ref_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.province_id,
                                  %2$s.name, %2$s.code FROM %1$I.%2$s UNION ', sch.short_name, 'districts');
                END LOOP;

                FOR ref_r IN EXECUTE left(sql, -7)
                LOOP
                  id := ref_r.id;
                  organization_name := ref_r.organization_name;
                  province_id := ref_r.province_id;
                  name := ref_r.name;
                  code := ref_r.code;
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_districts"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_districts"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_districts"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
