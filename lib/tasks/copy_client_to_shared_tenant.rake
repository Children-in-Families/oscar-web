namespace :client_to_shared do
  desc 'copy client to shared tenant'
  task :copy, [:short_name] => :environment do |task, args|
    clients = []
    cambodia_province_names = []
    thailand_province_names = []
    myanmar_states = []
    lesotho_suburbs = []

    Organization.switch_to args.short_name
    case args.short_name
    when 'gca'
      thailand_province_names.concat(Province.pluck(:name))
      clients << fetch_client_attributes('birth_province_name')
    when 'kmo'
      myanmar_states.concat(State.pluck(:name))
      clients << fetch_client_attributes('state_name')
    when 'spo'
      lesotho_suburbs = Client.pluck(:suburb).uniq
      clients << fetch_client_attributes('suburb')
    else
      cambodia_province_names.concat(Province.where(country: 'cambodia').where('name iLIKE ?', '%/%').pluck(:name))
      clients << fetch_client_attributes('birth_province_name')
    end


    Organization.switch_to 'shared'

    cambodia_province_names.uniq.each do |province_name|
      Province.find_or_create_by(name: province_name, country: 'cambodia')
    end

    thailand_province_names.uniq.each do |province_name|
      Province.find_or_create_by(name: province_name, country: 'thailand')
    end

    myanmar_states.uniq.each do |state|
      Province.find_or_create_by(name: state, country: 'myanmar')
    end

    lesotho_suburbs.each do |suburb|
      Province.find_or_create_by(name: suburb, country: 'lesotho')
    end

    clients.flatten.each do |client|
      province_id = nil
      if client['birth_province_name'].present?
        province_name = client['birth_province_name'].split('/').last
        found_province = Province.where("name iLIKE ?", "#{province_name}%/%")
        if found_province.first.nil?
          province_name = client['birth_province_name'].split('/').last
          province_name = province_name == " Oddar Meanchay" ? " Oddar Meanchey" : province_name
          province_name = province_name == "Communex" ? "Kampong Cham" : province_name
          province_name = province_name == ' Siem Reap' ? "Siemreap" : province_name
          province_name = province_name == ' Preah Sihannouk' ? "Preah Sihanouk" : province_name
          province_name = province_name == 'Poipet' ? "Banteay Meanchey" : province_name
          province_name = province_name == ' Mondulkiri' ? "Mondul Kiri" : province_name
          province_name = province_name == ' Ratanakiri' ? "Ratanak Kiri" : province_name
          province_name = province_name == ' Tboung Khmum​' ? "Tboung Khmum" : province_name
          found_province = Province.where("name iLIKE ?", "%#{province_name}%")
        end
        if found_province.first.nil?
          found_province = Province.where(name: province_name)
        end
        puts province_name

        next if ['Myanmar', 'Malaysia ', 'Community', ' ផ្សេងៗ', ' Outside Cambodia', 'Thailand', 'Burmese', 'Myawaddy'].include?(province_name)
        province_id = found_province.try(:id)
      end
      SharedClient.find_or_create_by(client.except('birth_province_name').merge({ birth_province_id: province_id }))
    end
    Apartment::Tenant.switch! args.short_name
  end
end

private

def fetch_client_attributes(birth_province)
  clients = []
  Client.all.each do |client|
    clients << client.slice(:given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :slug, :archived_slug, :live_with, :telephone_number, :country_origin).merge({ birth_province_name: client.send(birth_province) })
  end
  clients
end
