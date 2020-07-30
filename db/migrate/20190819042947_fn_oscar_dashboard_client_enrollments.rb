class FnOscarDashboardClientEnrollments < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_client_enrollments"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "client_id" int4, "program_stream_id" int4, "status" varchar, "enrollment_date" varchar, "created_at" varchar, "updated_at" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                donor_sql TEXT := '';
                cnrm_r record;
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
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.client_id, %2$s.program_stream_id,
                                   %2$s.status, %2$s.enrollment_date, %2$s.created_at, %2$s.updated_at FROM %1$I.%2$s
                                   INNER JOIN %1$I.clients ON %1$I.clients.id = %1$I.%2$s.client_id
                                   INNER JOIN %1$I.sponsors ON %1$I.sponsors.client_id = %1$I.clients.id
                                   INNER JOIN %1$I.donors ON %1$I.donors.id = %1$I.sponsors.donor_id
                                   WHERE %1$I.%2$s.deleted_at IS NULL AND %1$I.sponsors.donor_id IN (%3$s) UNION ',
                                  sch.short_name, 'client_enrollments', donor_sql);
                END LOOP;

                FOR cnrm_r IN EXECUTE left(sql, -7)
                LOOP
                  id := cnrm_r.id;
                  organization_name := cnrm_r.organization_name;
                  client_id := cnrm_r.client_id;
                  program_stream_id := cnrm_r.program_stream_id;
                  status := cnrm_r.status;
                  enrollment_date := timezone('Asia/Bangkok', cnrm_r.enrollment_date);
                  created_at := timezone('Asia/Bangkok', cnrm_r.created_at);
                  updated_at := timezone('Asia/Bangkok', cnrm_r.updated_at);
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
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_client_enrollments"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_client_enrollments"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
