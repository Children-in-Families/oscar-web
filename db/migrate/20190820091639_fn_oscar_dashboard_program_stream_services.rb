class FnOscarDashboardProgramStreamServices < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_program_stream_services"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "program_stream_id" int4, "service_id" int4) AS $BODY$
            DECLARE
              sql TEXT := '';
              sch record;
              ps_service_r record;
            BEGIN
              FOR sch IN
                SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                WHERE "public"."donors"."global_id" = donor_global_id
              LOOP
                sql := sql || format(
                                'SELECT %2$s.id, %1$L organization_name, %2$s.program_stream_id, %2$s.service_id FROM %1$I.%2$s UNION ',
                                sch.short_name, 'program_stream_services');
              END LOOP;

              FOR ps_service_r IN EXECUTE left(sql, -7)
              LOOP
                id := ps_service_r.id;
                organization_name := ps_service_r.organization_name;
                program_stream_id := ps_service_r.program_stream_id;
                service_id := ps_service_r.service_id;
                RETURN NEXT;
              END LOOP;
            END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_program_stream_services"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_program_stream_services"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_program_stream_services"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
