class FnOscarDashboardAssessmentDomains < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_assessment_domains"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "assessment_id" int4,"domain_id" int4, "score" int4) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                assdm_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.domain_id, %2$s.assessment_id,
                                   %2$s.score FROM %1$I.%2$s UNION ',
                                  sch.short_name, 'assessment_domains');
                END LOOP;

                FOR assdm_r IN EXECUTE left(sql, -7)
                LOOP
                  id := assdm_r.id;
                  organization_name := assdm_r.organization_name;
                  assessment_id := assdm_r.assessment_id;
                  domain_id := assdm_r.domain_id;
                  score := assdm_r.score;
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_assessment_domains"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_assessment_domains"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_assessment_domains"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
