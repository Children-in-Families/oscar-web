namespace :client_to_shared do
  desc 'copy client to shared tenant'
  task copy: :environment do
    clients = []

    Organization.switch_to 'cct'
    clients << fetch_client_attributes('birth_province_name')

    Organization.switch_to 'shared'

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
