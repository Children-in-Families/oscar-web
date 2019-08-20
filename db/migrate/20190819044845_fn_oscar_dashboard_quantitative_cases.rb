class FnOscarDashboardQuantitativeCases < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_quantitative_cases"()
              RETURNS TABLE("id" int4, "organization_name" varchar, "quantitative_type_id" int4, "value" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                qc_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."name" = 'Save the Children'
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.quantitative_type_id, %2$s.value
                                   FROM %1$I.%2$s UNION ',
                                  sch.short_name, 'quantitative_cases');
                END LOOP;

                FOR qc_r IN EXECUTE left(sql, -7)
                LOOP
                  id := qc_r.id;
                  organization_name := qc_r.organization_name;
                  quantitative_type_id := qc_r.quantitative_type_id;
                  value := qc_r.value;
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
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_quantitative_cases"() CASCADE;
          SQL
        end
      end
    end
  end
end
