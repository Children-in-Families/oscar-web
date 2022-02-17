class CreateDonorOrganization < ActiveRecord::Migration
  def change
    create_table :donor_organizations do |t|
      t.references :donor, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true
    end

    reversible do |dir|
      dir.up do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            DO
            $$
              BEGIN
                IF not EXISTS (SELECT column_name
                               FROM information_schema.columns
                               WHERE table_schema='public' and table_name='donors' and column_name='global_id') THEN
                  ALTER TABLE donors ADD COLUMN global_id varchar(32) NOT NULL DEFAULT '';
                else
                  raise NOTICE 'Already exists';
                END IF;
              END
            $$
          SQL

          create_donors_organizations

          execute <<-SQL.squish
            DO
            $$
            BEGIN
               IF to_regclass('public.index_donors_on_global_id') IS NULL THEN
                  CREATE INDEX index_donors_on_global_id ON public.donors USING btree (global_id);
               END IF;
            END
            $$;

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
            GRANT SELECT ON ALL TABLES IN SCHEMA public TO "#{ENV['READ_ONLY_DATABASE_USER']}";

            CREATE OR REPLACE FUNCTION get_birth_province_name(province_id int)
            RETURNS TEXT AS $$
            DECLARE p_name TEXT;
            BEGIN
                    SELECT  shared.provinces.name INTO p_name
                    FROM shared.provinces
                    WHERE   shared.provinces.id = $1;

                    RETURN p_name;
            END;
            $$  LANGUAGE plpgsql
                VOLATILE SECURITY DEFINER;

            CREATE OR REPLACE FUNCTION "public"."fn_oscar_dashboard_clients"(donor_global_id text)
              RETURNS TABLE("id" int4, "slug" varchar, "organization_name" varchar, "gender" varchar, "date_of_birth" varchar,
                            "status" varchar, "donor_id" int4, "province_id" int4, "province_name" varchar, "district_id" int4, "district_name" varchar,
                            "birth_province_id" int4, "assessments_count" int4, "follow_up_date" varchar, "initial_referral_date" varchar,
                            "exit_date" varchar, "accepted_date" varchar, "referral_source_category_id" int4, "created_at" varchar,
                            "updated_at" varchar) AS $BODY$
                DECLARE
                  sql TEXT := '';
                  sch record;
                  shared_bp_name TEXT := '';
                  donor_sql TEXT := '';
                  client_r record;
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
                                    'SELECT clients.id, clients.slug, %1$L organization_name, clients.gender, clients.donor_id, clients.exit_date, clients.accepted_date,
                                    clients.date_of_birth, clients.status, clients.province_id, provinces.name as province_name, clients.district_id, districts.name as district_name,
                                    clients.birth_province_id, clients.assessments_count, clients.follow_up_date,
                                    clients.initial_referral_date, clients.referral_source_category_id, clients.created_at,
                                    clients.updated_at FROM %1$I.clients INNER JOIN %1$I.sponsors ON %1$I.sponsors.client_id = %1$I.clients.id INNER JOIN %1$I.donors ON %1$I.donors.id = %1$I.sponsors.donor_id LEFT OUTER JOIN %1$I.provinces ON %1$I.provinces.id = %1$I.clients.province_id
                                    LEFT OUTER JOIN %1$I.districts ON %1$I.districts.id = %1$I.clients.district_id WHERE %1$I.sponsors.donor_id IN (%2$s) UNION ',
                                    sch.short_name, donor_sql);
                  END LOOP;

                  FOR client_r IN EXECUTE left(sql, -7)
                  LOOP
                    id := client_r.id; slug := client_r.slug; organization_name := client_r.organization_name; gender := client_r.gender;
                    donor_id := client_r.donor_id; exit_date := timezone('Asia/Bangkok', client_r.exit_date);
                    accepted_date := timezone('Asia/Bangkok', client_r.accepted_date);
                    date_of_birth := date(client_r.date_of_birth); status := client_r.status;
                    province_id := client_r.province_id; province_name := client_r.province_name;
                    district_id := client_r.district_id; district_name := client_r.district_name;
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

            GRANT EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_clients"(varchar) TO "#{ENV['POWER_BI_GROUP']}";
            -- REVOKE ALL ON ALL TABLES IN SCHEMA  pg_catalog FROM public, "#{ENV['POWER_BI_GROUP']}";
          SQL
        end
      end

      dir.down do
        if schema_search_path =~ /^\"public\"/
          execute <<-SQL.squish
            -- DROP INDEX IF EXISTS index_donors_on_global_id CASCADE;
            -- ALTER TABLE donors DROP COLUMN IF EXISTS global_id;
            DROP TABLE IF EXISTS donor_organizations CASCADE;

            REVOKE CONNECT ON DATABASE "#{ENV['DATABASE_NAME']}" FROM "#{ENV['POWER_BI_GROUP']}";
            REVOKE USAGE ON SCHEMA public FROM "#{ENV['POWER_BI_GROUP']}";

            REVOKE EXECUTE ON FUNCTION "public"."fn_oscar_dashboard_clients"(varchar) FROM "#{ENV['POWER_BI_GROUP']}";
            DROP FUNCTION IF EXISTS "public"."fn_oscar_dashboard_clients"(varchar) CASCADE;
            -- DROP OWNED BY "#{ENV['POWER_BI_GROUP']}";
            -- DROP ROLE IF EXISTS "#{ENV['POWER_BI_GROUP']}";
            -- DROP USER IF EXISTS "#{ENV['READ_ONLY_DATABASE_USER']}";
          SQL
        end
      end
    end
  end

  def create_donors_organizations
    Organization.switch_to 'public'
    donors = [ENV['STC_DONOR_NAME'], ENV['FD_DONOR_NAME']]
    donor_organizations = {
      ENV['STC_DONOR_NAME'] => [
        'Children In Families',
        'This Life Cambodia',
        'First Step Cambodia',
        "Cambodian Children's Trust",
        "M'lop Tapang",
        "Children's Future International",
        'Kaliyan Mith',
        'Mith Samlanh',
        'Friends International',
        'KOMAR RIKREAY CAMBODIA',
        'Holt International Cambodia',
        'Voice'
      ],
      ENV['FD_DONOR_NAME'] => [
        'Kaliyan Mith',
        'Mith Samlanh',
        'Friends International'
      ]
    }

    donors.map{ |donor_name| { name: donor_name } }.each do |donor|
      Donor.find_or_create_by(donor)
    end

    donor_orgs = []
    Donor.all.pluck(:id, :name).each do |donor_id, donor_name|
      organaization_names = donor_organizations[donor_name]
      organaization_names.each do |org_name|
        organization = Organization.where("LOWER(organizations.full_name) ILIKE (?)", "%#{org_name.downcase}%").first
        next unless organization
        donor_orgs << { donor_id: donor_id, organization_id: organization.id }
      end
    end

    donor_orgs.uniq.each do |donor_org|
      DonorOrganization.find_or_create_by(donor_org)
    end

    Donor.all.each do |donor|
      next if donor.global_id.present?
      donor.update(global_id: ULID.generate)
    end
  end
end
