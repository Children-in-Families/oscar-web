class FnOscarDashboardReferralSources < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_referral_sources"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "name" varchar, "clients_count" int4, "name_en" varchar, "description" text, "ancestry" varchar) AS $BODY$
            DECLARE
              sql TEXT := '';
              sch record;
              ref_source_r record;
            BEGIN
              FOR sch IN
                SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                WHERE "public"."donors"."global_id" = donor_global_id
              LOOP
                sql := sql || format(
                                'SELECT %2$s.id, %1$L organization_name, %2$s.name, %2$s.clients_count, %2$s.name_en, %2$s.description, %2$s.ancestry FROM %1$I.%2$s UNION ',
                                sch.short_name, 'referral_sources');
              END LOOP;

              FOR ref_source_r IN EXECUTE left(sql, -7)
              LOOP
                id := ref_source_r.id;
                organization_name := ref_source_r.organization_name;
                name := ref_source_r.name;
                clients_count := ref_source_r.clients_count;
                name_en := ref_source_r.name_en;
                description := ref_source_r.description;
                ancestry := ref_source_r.ancestry;
                RETURN NEXT;
              END LOOP;
            END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_referral_sources"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_referral_sources"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_referral_sources"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
