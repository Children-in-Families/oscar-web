class FnOscarDashboardReferrals < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_referrals"(donor_global_id varchar DEFAULT '')
              RETURNS TABLE("id" int4, "organization_name" varchar, "client_id" int4, "referred_to" varchar, "referred_from" varchar, "date_of_referral" varchar) AS $BODY$
              DECLARE
                sql TEXT := '';
                sch record;
                ref_r record;
              BEGIN
                FOR sch IN
                  SELECT organizations.full_name, organizations.short_name FROM "public"."donors"
                  INNER JOIN "public"."donor_organizations" ON "public"."donor_organizations"."donor_id" = "public"."donors"."id"
                  INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."donor_organizations"."organization_id"
                  WHERE "public"."donors"."global_id" = donor_global_id
                LOOP
                  sql := sql || format(
                                  'SELECT %2$s.id, %1$L organization_name, %2$s.client_id,
                                  %2$s.referred_to, %2$s.referred_from, %2$s.date_of_referral
                                  FROM %1$I.%2$s UNION ', sch.short_name, 'referrals');
                END LOOP;

                FOR ref_r IN EXECUTE left(sql, -7)
                LOOP
                  id := ref_r.id;
                  organization_name := ref_r.organization_name;
                  client_id := ref_r.client_id;
                  referred_to := ref_r.referred_to;
                  referred_from := ref_r.referred_from;
                  date_of_referral := timezone('Asia/Bangkok', ref_r.date_of_referral);
                  RETURN NEXT;
                END LOOP;
              END
            $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_referrals"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_referrals"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_referrals"(varchar) CASCADE;
          SQL
        end
      end
    end
  end
end
