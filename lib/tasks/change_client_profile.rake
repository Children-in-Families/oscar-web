namespace :change_client_profile do
  desc 'Faking client data in development, staging and demo environment.'
  task :update, [:short_name] => :environment do |task, args|
    if Rails.env.development? || Rails.env.staging? || Rails.env.demo?
      Organization.switch_to args.short_name
      province_ids = Province.ids
      district_ids = []
      commune_ids  = []
      village_ids  = []

      values = Client.all.map do |client|
        client.given_name = FFaker::Name.first_name
        client.family_name = FFaker::Name.last_name
        client.local_given_name = client.given_name
        client.local_family_name = client.family_name
        # client.gender = client.gender == 'male' ? 'female' : 'male'

        if province_ids.present?
          current_province_ids = province_ids - [client.province_id]
          province_id          = current_province_ids.sample
          district_ids         = Province.find(province_id).district_ids if province_id.present?
          district_id          = district_ids.sample
          commune_ids          = District.find(district_id).commune_ids if district_id.present?
          commune_id           = commune_ids.sample
          village_ids          = Commune.find(commune_id).village_ids if commune_id.present?
        end

        country_name = Setting.first.country_name
        client_birth_province = client.birth_province_id.present? ? " AND shared.provinces.id != #{client.birth_province_id}" : ''
        birth_province_ids = ActiveRecord::Base.connection.execute("SELECT id FROM shared.provinces WHERE country = '#{country_name}'#{client_birth_province}").values.flatten

        client.province_id = province_id
        client.district_id = district_id
        client.commune_id = commune_id
        client.village_id = village_ids.sample
        client.birth_province_id = birth_province_ids.sample

        "(#{client.id}, '#{client.given_name.gsub("'", "''")}', '#{client.family_name.gsub("'", "''")}', '#{client.local_given_name.gsub("'", "''")}', '#{client.local_family_name.gsub("'", "''")}', '#{client.gender.gsub("'", "''")}')"
        # "(#{client.id}, '#{client.given_name.gsub("'", "''")}', '#{client.family_name.gsub("'", "''")}', '#{client.local_given_name.gsub("'", "''")}', '#{client.local_family_name.gsub("'", "''")}', '#{client.gender.gsub("'", "''")}', #{client.province_id}, #{client.district_id}, #{client.commune_id}, #{client.village_id}, #{client.birth_province_id})"
      end.join(", ")

      sql = <<-SQL.squish
        UPDATE clients SET given_name = mapping_values.client_first, family_name = mapping_values.client_last, local_given_name = mapping_values.client_local_first, local_family_name = mapping_values.client_local_last, gender = mapping_values.gender FROM (VALUES #{values}) AS mapping_values (client_id, client_first, client_last, client_local_first, client_local_last, gender) WHERE clients.id = mapping_values.client_id;
        -- UPDATE clients SET given_name = mapping_values.client_first, family_name = mapping_values.client_last, local_given_name = mapping_values.client_local_first, local_family_name = mapping_values.client_local_last, gender = mapping_values.gender, province_id = mapping_values.province, district_id = mapping_values.district, commune_id = mapping_values.commune, village_id = mapping_values.village, birth_province_id = mapping_values.birth_province FROM (VALUES #{values}) AS mapping_values (client_id, client_first, client_last, client_local_first, client_local_last, gender, province, district, commune, village, birth_province) WHERE clients.id = mapping_values.client_id;
      SQL
      ActiveRecord::Base.connection.execute(sql) if values.present?
      puts 'Done updating!!!'
    end
  end
end
