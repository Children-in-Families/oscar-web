namespace :client_siemreap_birth_province do
  desc "Correct birht province from Seam Reap to Siemreap"
  task correct: :environment do
    Organization.switch_to 'shared'
    wrong_siem_reap_id = Province.find_by(name: "សៀមរាប/Seam Reap").id
    correct_siem_reap_id = Province.find_by(name: "សៀមរាប / Siemreap").id
    if wrong_siem_reap_id
      SharedClient.where(birth_province_id: wrong_siem_reap_id).update_all(birth_province_id: correct_siem_reap_id)
      Organization.where.not(short_name: 'shared').pluck(:short_name).each do |short_name|
        Organization.switch_to short_name
        Client.where(birth_province_id: wrong_siem_reap_id).update_all(birth_province_id: correct_siem_reap_id)
      end
      Organization.switch_to 'shared'
      Province.find_by(name: "សៀមរាប/Seam Reap").delete
    end
    puts "Done !!!!!"
  end

end
