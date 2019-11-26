namespace :change_client_profile do
  desc 'Faking client data in development, staging and demo environment.'
  task :update, [:short_name] => :environment do |task, args|
    if Rails.env.development? || Rails.env.staging? || Rails.env.demo?
      Organization.switch_to args.short_name
      province_ids = Province.ids
      district_ids = []
      commune_ids  = []
      village_ids  = []

      Client.all.each do |client|
        client.given_name = FFaker::Name.first_name
        client.family_name = FFaker::Name.last_name
        client.local_given_name = client.given_name
        client.local_family_name = client.family_name
        client.gender = client.gender == 'male' ? 'female' : 'male'

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

        client.save(validate: false)
      end
      puts 'Done updating!!!'
    end
  end
end
