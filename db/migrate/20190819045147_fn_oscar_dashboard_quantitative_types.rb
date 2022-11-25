class FnOscarDashboardQuantitativeTypes < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_quantitative_types"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "name" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                qt_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.name
                                   FROM %1$I.%2$s UNION ',
                                  sch.short_name, 'quantitative_types');
                END LOOP;

                FOR qt_r IN EXECUTE left(sql, -7)
                LOOP
                  id := qt_r.id;
                  organization_name := qt_r.organization_name;
                  name := qt_r.name;
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_quantitative_types"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_quantitative_types"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_quantitative_types"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
