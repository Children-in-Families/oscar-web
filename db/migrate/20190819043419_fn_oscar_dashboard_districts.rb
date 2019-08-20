class FnOscarDashboardDistricts < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_districts"()
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
                  WHERE "public"."donors"."name" = 'Save the Children'
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
              LANGUAGE plpgsql VOLATILE
              COST 100
              ROWS 1000
          SQL
        end
      end

      dir.down do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_districts"() CASCADE;
          SQL
        end
      end
    end
  end
end
