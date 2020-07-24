class FnOscarDashboardAssessments < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_assessments"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "client_id" int4, "completed" bool, "default_assessment" bool, "created_at" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                donor_sql TEXT := '';
                assm_r record;
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
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.client_id,
                                   %2$s.completed, %2$s.default as default_assessment, %2$s.created_at FROM %1$I.%2$s
                                   INNER JOIN %1$I.clients ON %1$I.clients.id = %1$I.assessments.client_id
                                   INNER JOIN %1$I.sponsors ON %1$I.sponsors.client_id = %1$I.clients.id
                                   INNER JOIN %1$I.donors ON %1$I.donors.id = %1$I.sponsors.donor_id
                                   WHERE %1$I.sponsors.donor_id IN (%3$s) UNION ',
                                  sch.short_name, 'assessments', donor_sql);
                END LOOP;

                FOR assm_r IN EXECUTE left(sql, -7)
                LOOP
                  id := assm_r.id;
                  organization_name := assm_r.organization_name;
                  client_id := assm_r.client_id;
                  completed := assm_r.completed;
                  default_assessment := assm_r.default_assessment;
                  created_at := timezone('Asia/Bangkok', assm_r.created_at);
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_assessments"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_assessments"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_assessments"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
