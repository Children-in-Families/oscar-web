namespace :client_to_shared do
  desc 'copy client to shared tenant'
  task copy: :environment do
    clients = []
    cambodia_province_names = []
    thailand_province_names = []
    myanmar_states = []
    lesotho_suburbs = []

    Organization.all.each do |org|
      Organization.switch_to org.short_name
      case org.short_name
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
        cambodia_province_names.concat(Province.pluck(:name))
        clients << fetch_client_attributes('birth_province_name')
      end
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
        province = client['birth_province_name'].split('/').last.strip
        province_id = Province.where("name ilike ?", "%#{province}%").first.try(:id)
      end
      SharedClient.find_or_create_by(client.except('birth_province_name').merge({ birth_province_id: province_id }))
    end
  end
end

private

def fetch_client_attributes(birth_province)
  clients = []
  Client.all.each do |client|
    clients << client.slice(:given_name, :family_name, :local_given_name, :local_family_name, :gender, :date_of_birth, :slug, :live_with, :telephone_number, :country_origin).merge({ birth_province_name: client.send(birth_province) })
  end
  clients
end
