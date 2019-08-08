class CreateAllDonorOrganization < ActiveRecord::Migration
  def change
    create_table :all_donor_organizations do |t|
      t.references :all_donor, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true
    end

    reversible do |dir|
      dir.up do
        if schema_search_path == "\"public\""
          create_all_donors_organizations
          execute <<-SQL.squish
            DO
            $do$
            BEGIN
               IF NOT EXISTS (
                  SELECT FROM pg_catalog.pg_roles
                  WHERE rolname = '#{ENV['READ_ONLY_DATABASE_USER']}') THEN
                  CREATE ROLE "#{ENV['POWER_BI_GROUP']}" WITH LOGIN ENCRYPTED PASSWORD '#{ENV['READ_ONLY_DATABASE_PASSWORD']}';
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
                  sql TEXT := '';
                  sch record;
                  client_r record;
                BEGIN
                  FOR sch IN
                    SELECT organizations.full_name, organizations.short_name FROM "public"."all_donors"
                    INNER JOIN "public"."all_donor_organizations" ON "public"."all_donor_organizations"."all_donor_id" = "public"."all_donors"."id"
                    INNER JOIN "public"."organizations" ON "public"."organizations"."id" = "public"."all_donor_organizations"."organization_id"
                    WHERE "public"."all_donors"."name" = 'Save the Children'
                  LOOP
                    sql := sql || format(
                                    'SELECT clients.id AS client_id, %L organization_name, clients.gender,
                                    clients.date_of_birth, clients.status, clients.province_id, clients.district_id,
                                    clients.birth_province_id, clients.assessments_count, clients.follow_up_date,
                                    clients.initial_referral_date, clients.referral_source_category_id, clients.created_at,
                                    clients.updated_at FROM %I.clients UNION ',
                                    sch.full_name, sch.short_name);
                  END LOOP;

                  FOR client_r IN EXECUTE left(sql, -7)
                  LOOP
                    client_id := client_r.client_id; organization_name := client_r.organization_name; gender := client_r.gender;
                    date_of_birth := date(client_r.date_of_birth); status := client_r.status;
                    province_id := client_r.province_id; district_id := client_r.district_id;
                    birth_province_id := client_r.birth_province_id; assessments_count := client_r.assessments_count;
                    follow_up_date := client_r.follow_up_date; initial_referral_date := date(client_r.initial_referral_date);
                    referral_source_category_id := client_r.referral_source_category_id; created_at := timezone('Asia/Bangkok',
                    client_r.created_at); updated_at := timezone('Asia/Bangkok', client_r.updated_at);
                    RETURN NEXT;
                  END LOOP;

              END; $BODY$
              LANGUAGE plpgsql VOLATILE SECURITY DEFINER
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

  def create_all_donors_organizations
    Organization.switch_to 'public'
    donors = ['Save the Children', 'Friends']
    donor_organizations = {
      'Save the Children' => [
        'Children in Families',
        'This Life Cambodia',
        'First Step Cambodia',
        "Cambodian Children's Trust",
        "M'lop Tapang",
        "Children's Future International",
        'Kaliyan Mith',
        'Mith Samlanh',
        'Friends International',
        'KMR',
        'Holt',
        'Tentative - Voice'
      ],
      'Friends' => [
        'Kaliyan Mith',
        'Mith Samlanh',
        'Friends International'
      ]
    }

    donors.map{ |donor_name| { name: donor_name } }.each do |donor|
      AllDonor.find_or_create_by(donor)
    end

    donor_orgs = []
    AllDonor.all.pluck(:id, :name).each do |donor_id, donor_name|
      organaization_names = donor_organizations[donor_name]
      organaization_names.each do |org_name|
        organization = Organization.where("LOWER(organizations.full_name) ILIKE (?)", "%#{org_name}%").first
        next unless organization
        donor_orgs << { all_donor_id: donor_id, organization_id: organization.id }
      end
    end

    donor_orgs.uniq.each do |donor_org|
      AllDonorOrganization.find_or_create_by(donor_org)
    end
  end
end
