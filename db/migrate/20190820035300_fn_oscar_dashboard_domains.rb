class FnOscarDashboardDomains < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_domains"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "name" varchar, "identity" varchar, "description" text, "domain_group_id" int4, "score_1_color" text, "score_2_color" text, "score_3_color" text, "score_4_color" text, "score_1_definition" text, "score_2_definition" text, "score_3_definition" text, "score_4_definition" text, "local_description" text, "score_1_local_definition" text, "score_2_local_definition" text, "score_3_local_definition" text, "score_4_local_definition" text, "custom_domain" bool) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                domain_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name,
                                  %2$s.name, %2$s.identity, %2$s.description, %2$s.domain_group_id, %2$s.score_1_color,
                                  %2$s.score_2_color, %2$s.score_3_color, %2$s.score_4_color, %2$s.score_1_definition,
                                  %2$s.score_2_definition, %2$s.score_3_definition, %2$s.score_4_definition,
                                  %2$s.local_description, %2$s.score_1_local_definition, %2$s.score_2_local_definition,
                                  %2$s.score_3_local_definition, %2$s.score_4_local_definition, %2$s.custom_domain
                                  FROM %1$I.%2$s UNION ', sch.short_name, 'domains');
                END LOOP;

                FOR domain_r IN EXECUTE left(sql, -7)
                LOOP
                  id := domain_r.id;
                  organization_name := domain_r.organization_name;
                  name := domain_r.name;
                  identity := domain_r.identity;
                  description := domain_r.description;
                  domain_group_id := domain_r.domain_group_id;
                  score_1_color := domain_r.score_1_color;
                  score_2_color := domain_r.score_2_color;
                  score_3_color := domain_r.score_3_color;
                  score_4_color := domain_r.score_4_color;
                  score_1_definition := domain_r.score_1_definition;
                  score_2_definition := domain_r.score_2_definition;
                  score_3_definition := domain_r.score_3_definition;
                  score_4_definition := domain_r.score_4_definition;
                  local_description := domain_r.local_description;
                  score_1_local_definition := domain_r.score_1_local_definition;
                  score_2_local_definition := domain_r.score_2_local_definition;
                  score_3_local_definition := domain_r.score_3_local_definition;
                  score_4_local_definition := domain_r.score_4_local_definition;
                  custom_domain := domain_r.custom_domain;
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_domains"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_domains"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_domains"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
