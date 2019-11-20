class FnOscarDashboardCaseNotes < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_case_notes"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "client_id" int4, "meeting_date" text) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                cn_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.client_id,
                                   %2$s.meeting_date FROM %1$I.%2$s UNION ',
                                  sch.short_name, 'case_notes');
                END LOOP;

                FOR cn_r IN EXECUTE left(sql, -7)
                LOOP
                  id := cn_r.id;
                  organization_name := cn_r.organization_name;
                  client_id := cn_r.client_id;
                  meeting_date := timezone('Asia/Bangkok', cn_r.meeting_date);
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_case_notes"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_case_notes"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_case_notes"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
