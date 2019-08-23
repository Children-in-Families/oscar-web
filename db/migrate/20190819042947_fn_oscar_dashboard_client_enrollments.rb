class FnOscarDashboardClientEnrollments < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_client_enrollments"(donor_name varchar DEFAULT 'Save the Children')
              RETURNS TABLE("id" int4, "organization_name" varchar, "client_id" int4, "program_stream_id" int4, "status" varchar, "enrollment_date" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                cnrm_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."name" = donor_name
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.client_id, %2$s.program_stream_id,
                                   %2$s.status, %2$s.enrollment_date FROM %1$I.%2$s UNION ',
                                  sch.short_name, 'client_enrollments');
                END LOOP;

                FOR cnrm_r IN EXECUTE left(sql, -7)
                LOOP
                  id := cnrm_r.id;
                  organization_name := cnrm_r.organization_name;
                  client_id := cnrm_r.client_id;
                  program_stream_id := cnrm_r.program_stream_id;
                  status := cnrm_r.status;
                  enrollment_date := timezone('Asia/Bangkok', cnrm_r.enrollment_date);
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_client_enrollments"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_client_enrollments"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_client_enrollments"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
