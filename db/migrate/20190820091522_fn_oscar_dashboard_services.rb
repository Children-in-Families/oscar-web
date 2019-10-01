class FnOscarDashboardServices < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_services"(public_donor_id int4 DEFAULT 1)
              RETURNS TABLE("id" int4, "organization_name" varchar, "name" varchar, "parent_id" int4) AS $BODY$
            DECLARE
              sql TEXT := '';
              sch record;
              service_r record;
            BEGIN
              FOR sch IN
                SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                WHERE "public"."donors"."id" = public_donor_id
              LOOP
                sql := sql || format(
                                'SELECT %2$s.id, %1$L organization_name, %2$s.name, %2$s.parent_id FROM %1$I.%2$s UNION ',
                                sch.short_name, 'services');
              END LOOP;

              FOR service_r IN EXECUTE left(sql, -7)
              LOOP
                id := service_r.id;
                organization_name := service_r.organization_name;
                name := service_r.name;
                parent_id := service_r.parent_id;
                RETURN NEXT;
              END LOOP;
            END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_services"(int4) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_services"(int4) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_services"(int4) CASCADE;
          SQL
        end
      end
    end
  end
end
