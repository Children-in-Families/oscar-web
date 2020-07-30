class FnOscarDashboardLeavePrograms < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_leave_programs"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "program_stream_id" int4, "client_enrollment_id" int4, "exit_date" varchar, "properties" jsonb, "deleted_at" varchar, "created_at" varchar, "updated_at" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                donor_sql TEXT := '';
                lp_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  IF (SELECT name FROM public.donors WHERE public.donors.global_id = donor_global_id) = '#{ENV['STC_DONOR_NAME']}' THEN
                    donor_sql := format('SELECT %1$I.donors.id FROM donors WHERE (LOWER(%1$I.donors.name) = %2$L OR LOWER(%1$I.donors.name) = %3$L)', sch.short_name, 'fcf', 'react');
                  ELSE
                    donor_sql := format('SELECT %1$I.donors.id FROM donors WHERE (LOWER(%1$I.donors.name) IN (%2$L, %3$L, %4$L))', sch.short_name, '3pc unicef', '3pc react', '3pc global fund');
                  END IF;
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.properties, %2$s.program_stream_id,
                                   %2$s.client_enrollment_id, %2$s.exit_date, %2$s.deleted_at, %2$s.created_at, %2$s.updated_at FROM %1$I.%2$s
                                   INNER JOIN %1$I.client_enrollments ON %1$I.client_enrollments.id = %1$I.leave_programs.client_enrollment_id AND %1$I.client_enrollments.deleted_at IS NULL
                                   INNER JOIN %1$I.clients ON %1$I.clients.id = %1$I.client_enrollments.client_id INNER JOIN %1$I.sponsors ON %1$I.sponsors.client_id = %1$I.clients.id
                                   INNER JOIN %1$I.donors ON %1$I.donors.id = %1$I.sponsors.donor_id
                                   WHERE %1$I.leave_programs.deleted_at IS NULL AND %1$I.sponsors.donor_id IN (%3$s) UNION ',
                                  sch.short_name, 'leave_programs', donor_sql);
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
                  created_at := timezone('Asia/Bangkok', lp_r.created_at);
                  updated_at := timezone('Asia/Bangkok', lp_r.updated_at);
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
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_leave_programs"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_leave_programs"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
