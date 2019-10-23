class FnOscarDashboardLeavePrograms < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_leave_programs"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "program_stream_id" int4, "client_enrollment_id" int4, "exit_date" varchar, "properties" jsonb, "deleted_at" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                lp_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.properties, %2$s.program_stream_id,
                                   %2$s.client_enrollment_id, %2$s.exit_date, %2$s.deleted_at FROM %1$I.%2$s UNION ',
                                  sch.short_name, 'leave_programs');
                END LOOP;

                FOR lp_r IN EXECUTE left(sql, -7)
                LOOP
                  id := lp_r.id;
                  organization_name := lp_r.organization_name;
                  program_stream_id := lp_r.program_stream_id;
                  exit_date := timezone('Asia/Bangkok', lp_r.exit_date);
                  deleted_at := timezone('Asia/Bangkok', lp_r.deleted_at);
                  properties := lp_r.properties;
                  client_enrollment_id := lp_r.client_enrollment_id;
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_leave_programs"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_leave_programs"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_leave_programs"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
