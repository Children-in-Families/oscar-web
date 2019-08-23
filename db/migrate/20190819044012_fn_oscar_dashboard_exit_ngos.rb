class FnOscarDashboardExitNgos < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_exit_ngos"(donor_name varchar DEFAULT 'Save the Children')
              RETURNS TABLE("id" int4, "organization_name" varchar, "client_id" int4, "exit_reasons" varchar, "exit_circumstance" varchar, "exit_date" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                exit_ngo_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."name" = donor_name
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.client_id,
                                  %2$s.exit_reasons, %2$s.exit_circumstance, %2$s.exit_date
                                  FROM %1$I.%2$s UNION ', sch.short_name, 'exit_ngos');
                END LOOP;

                FOR exit_ngo_r IN EXECUTE left(sql, -7)
                LOOP
                  id := exit_ngo_r.id;
                  organization_name := exit_ngo_r.organization_name;
                  client_id := exit_ngo_r.client_id;
                  exit_reasons := exit_ngo_r.exit_reasons;
                  exit_circumstance := exit_ngo_r.exit_circumstance;
                  exit_date := timezone('Asia/Bangkok', exit_ngo_r.exit_date);
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_exit_ngos"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_exit_ngos"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_exit_ngos"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
