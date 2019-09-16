class FnOscarDashboardEnterNgos < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_enter_ngos"(donor_name varchar DEFAULT 'Save the Children')
              RETURNS TABLE("id" int4, "organization_name" varchar, "client_id" int4, "accepted_date" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                enter_ngo_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."name" = donor_name
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.client_id,
                                  %2$s.accepted_date FROM %1$I.%2$s UNION ',
                                  sch.short_name, 'enter_ngos');
                END LOOP;

                FOR enter_ngo_r IN EXECUTE left(sql, -7)
                LOOP
                  id := enter_ngo_r.id;
                  organization_name := enter_ngo_r.organization_name;
                  client_id := enter_ngo_r.client_id;
                  accepted_date := timezone('Asia/Bangkok', enter_ngo_r.accepted_date);
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_enter_ngos"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_enter_ngos"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_enter_ngos"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
