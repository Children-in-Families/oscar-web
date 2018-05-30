namespace :client_to_shared do
  desc 'copy client to shared tenant'
  task copy: :environment do
    clients = []
    cambodia_province_names = []
    thailand_province_names = []
    Organization.oscar.each do |org|
      Organization.switch_to org.short_name
      if org.short_name == 'cps'
        thailand_province_names.concat(Province.pluck(:name))
      elsif ['spo', 'kmo'].exclude?(org.short_name)
        cambodia_province_names.concat(Province.pluck(:name))
      end
      Client.find_each do |client|
        clients << client.slice(:given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :slug, :live_with, :telephone_number).merge({ birth_province_name: client.birth_province_name })
      end
    end
    Organization.switch_to 'shared'
    cambodia_province_names.uniq.each do |province_name|
      Province.create(name: province_name, country: 'cambodia')
    end
    thailand_province_names.uniq.each do |province_name|
      Province.create(name: province_name, country: 'thailand')
    end
    clients.each do |client|
      province_id = nil
      if client['birth_province_name'].present?
        province = client['birth_province_name'].split('/').last.strip
        province_id = Province.where("name ilike ?", "%#{province}%").first.id
      end
      SharedClient.create(client.except('birth_province_name').merge({ birth_province_id: province_id }))
    end
  end
end
