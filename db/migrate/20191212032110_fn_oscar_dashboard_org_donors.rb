class FnOscarDashboardOrgDonors < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_org_donors"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "name" varchar, "code" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                donor_sql TEXT := '';
                donor_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  IF (SELECT public.donors.name FROM public.donors WHERE public.donors.global_id = donor_global_id) = '#{ENV['STC_DONOR_NAME']}' THEN
                    donor_sql := format('SELECT %1$I.donors.id FROM %1$I.donors WHERE (LOWER(%1$I.donors.name) = %2$L OR LOWER(%1$I.donors.name) = %3$L)', sch.short_name, 'fcf', 'react');
                  ELSE
                    donor_sql := format('SELECT %1$I.donors.id FROM %1$I.donors WHERE (LOWER(%1$I.donors.name) IN (%2$L, %3$L, %4$L))', sch.short_name, '3pc unicef', '3pc react', '3pc global fund');
                  END IF;
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.code, %2$s.name FROM %1$I.%2$s
                                  WHERE %1$I.%2$s.id IN (%3$s) UNION ',
                                  sch.short_name, 'donors', donor_sql);
                END LOOP;

                FOR donor_r IN EXECUTE left(sql, -7)
                LOOP
                  id := donor_r.id;
                  organization_name := donor_r.organization_name;
                  name := donor_r.name;
                  code := donor_r.code;
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_org_donors"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_org_donors"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_org_donors"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
