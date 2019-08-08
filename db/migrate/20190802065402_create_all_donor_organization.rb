class CreateAllDonorOrganization < ActiveRecord::Migration
  def change
    create_table :all_donor_organizations do |t|
      t.references :all_donor, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true
    end

    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          # create_all_donors
          execute <<-SQL.squish
            DO
            $do$
            BEGIN
               IF NOT EXISTS (
                  SELECT FROM pg_catalog.pg_roles
                  WHERE rolname = '#{ENV['READ_ONLY_DATABASE_USER']}') THEN
                  CREATE ROLE "#{ENV['POWER_BI_GROUP']}";
                  CREATE ROLE "#{ENV['READ_ONLY_DATABASE_USER']}" WITH LOGIN ENCRYPTED PASSWORD '#{ENV['READ_ONLY_DATABASE_PASSWORD']}' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION VALID UNTIL 'infinity';
                  GRANT "#{ENV['POWER_BI_GROUP']}" TO "#{ENV['READ_ONLY_DATABASE_USER']}";
               END IF;
            END
            $do$;

            GRANT CONNECT ON DATABASE "#{ENV['DATABASE_NAME']}" TO "#{ENV['POWER_BI_GROUP']}";
            GRANT USAGE ON SCHEMA public TO "#{ENV['POWER_BI_GROUP']}";

            CREATE OR REPLACE FUNCTION "public"."sp_oscar_dashboard_friends"()
              RETURNS TABLE("client_id" int4, "organization_name" varchar, "gender" varchar, "date_of_birth" varchar, "status" varchar, "province_id" int4, "district_id" int4, "birth_province_id" int4, "assessments_count" int4, "follow_up_date" varchar, "initial_referral_date" varchar, "referral_source_category_id" int4, "created_at" varchar, "updated_at" varchar) AS $BODY$
            DECLARE
                client_r record;
            BEGIN
                FOR client_r IN(SELECT
                                clients.id AS client_id,
                              'cif' constantvalue,
                              clients.gender,
                              clients.date_of_birth,
                              clients.status,
                              clients.province_id,
                              clients.district_id,
                              clients.birth_province_id,
                              clients.assessments_count,
                              clients.follow_up_date,
                              clients.initial_referral_date,
                              clients.referral_source_category_id,
                              clients.created_at,
                              clients.updated_at
                                FROM cif.clients
                                UNION
                                SELECT
                                clients.id AS client_id,
                              'mtp' constantvalue,
                              clients.gender,
                              clients.date_of_birth,
                              clients.status,
                              clients.province_id,
                              clients.district_id,
                              clients.birth_province_id,
                              clients.assessments_count,
                              clients.follow_up_date,
                              clients.initial_referral_date,
                              clients.referral_source_category_id,
                              clients.created_at,
                              clients.updated_at
                                FROM mtp.clients
                                UNION
                                SELECT
                                clients.id AS client_id,
                              'mtp' constantvalue,
                              clients.gender,
                              clients.date_of_birth,
                              clients.status,
                              clients.province_id,
                              clients.district_id,
                              clients.birth_province_id,
                              clients.assessments_count,
                              clients.follow_up_date,
                              clients.initial_referral_date,
                              clients.referral_source_category_id,
                              clients.created_at,
                              clients.updated_at
                                FROM demo.clients
                              )
               LOOP
                    client_id  := client_r.client_id;
                    organization_name := client_r.constantvalue;
                    gender := client_r.gender;
                    date_of_birth := date(client_r.date_of_birth);
                    status  := client_r.status;
                    province_id  := client_r.province_id;
                    district_id  := client_r.district_id;
                    birth_province_id  := client_r.birth_province_id;
                    assessments_count  := client_r.assessments_count;
                    follow_up_date  := client_r.follow_up_date;
                    initial_referral_date  := date(client_r.initial_referral_date);
                    referral_source_category_id  := client_r.referral_source_category_id;
                    created_at  := timezone('Asia/Bangkok', client_r.created_at);
                    updated_at := timezone('Asia/Bangkok', client_r.updated_at);
                    RETURN NEXT;
               END LOOP;
            END; $BODY$
              LANGUAGE plpgsql VOLATILE
              SECURITY DEFINER
              COST 100
              ROWS 1000;

            GRANT EXECUTE ON FUNCTION "public"."sp_oscar_dashboard_friends"() TO "#{ENV['POWER_BI_GROUP']}";
            ---REVOKE ALL ON ALL TABLES IN SCHEMA cif FROM public;
            ---REVOKE ALL ON ALL TABLES IN SCHEMA demo FROM public;
            ---REVOKE ALL ON ALL TABLES IN SCHEMA mtp FROM public;
          SQL
        end
      end

      dir.down do
        if schema_search_path == "\"public\""
          execute <<-SQL.squish
            REVOKE CONNECT ON DATABASE "#{ENV['DATABASE_NAME']}" FROM "#{ENV['POWER_BI_GROUP']}";
            REVOKE USAGE ON SCHEMA public FROM "#{ENV['POWER_BI_GROUP']}";

            REVOKE EXECUTE ON FUNCTION "public"."sp_oscar_dashboard_friends"() FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."sp_oscar_dashboard_friends"() CASCADE;
            DROP OWNED BY "#{ENV['POWER_BI_GROUP']}";
            DROP ROLE IF EXISTS "#{ENV['POWER_BI_GROUP']}";
            DROP USER IF EXISTS "#{ENV['READ_ONLY_DATABASE_USER']}";
          SQL
        end
      end
    end
  end

  def create_all_donors
    donors = Organization.pluck(:id, :short_name).map do |org_id, short_name|
      Organization.switch_to short_name
      Donor.all.map do |donor|
        [[org_id, short_name], [donor.id, donor.name]]
      end
    end

    donor_names = donors.reject(&:blank?).map do |group|
      group.flatten(1)[1..-1].map(&:last)
    end

    donor_values = donor_names.flatten.uniq.map{ |donor_name| { name: donor_name.strip } }

    Organization.switch_to 'public'

    org_donors = donors.reject(&:blank?).map do |group|
      org_donor = group.flatten(1).to_h.to_a
      org, donors = org_donor[0], org_donor[1..-1]

      donors.to_h.values.uniq.map{ |donor_name| { name: donor_name.strip } }.each do |donor|
        AllDonor.find_or_create_by(donor)
      end

      donors.to_h.values.uniq.map{ |donor_name| { organization_id: org[0], all_donor_id: AllDonor.find_by(name: donor_name.strip).id } }.each do |donor_org|
        AllDonorOrganization.find_or_create_by(donor_org)
      end
    end
  end
end
