class FnOscarDashboardDomainGroups < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_domain_groups"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "name" varchar,"description" text, "domains_count" int4) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                dmg_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.description, %2$s.name,
                                   %2$s.domains_count FROM %1$I.%2$s UNION ',
                                  sch.short_name, 'domain_groups');
                END LOOP;

                FOR dmg_r IN EXECUTE left(sql, -7)
                LOOP
                  id := dmg_r.id;
                  organization_name := dmg_r.organization_name;
                  name := dmg_r.name;
                  description := dmg_r.description;
                  domains_count := dmg_r.domains_count;
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_domain_groups"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_domain_groups"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_domain_groups"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
