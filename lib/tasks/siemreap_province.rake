namespace :siemreap_province do
  desc "Correct Seam Reap to Siemreap"
  task correct: :environment do
    Organization.without_shared.pluck(:short_name) do |short_name|
      Apartment::Tenant.switch short_nanme
      wrong_siem_reap_id = Province.find_by(name: "សៀមរាប/Seam Reap").id
      correct_siem_reap_id = Province.find_by(name: "សៀមរាប / Siemreap").id
      if wrong_siem_reap_id && correct_siem_reap_id
        Family.where(province_id: wrong_siem_reap_id).update_all(province_id: correct_siem_reap_id)
        Community.where(province_id: wrong_siem_reap_id).update_all(province_id: correct_siem_reap_id)
        User.where(province_id: wrong_siem_reap_id).update_all(province_id: correct_siem_reap_id)
        Partner.where(province_id: wrong_siem_reap_id).update_all(province_id: correct_siem_reap_id)
        Province.find_by(name: "សៀមរាប/Seam Reap").delete
      end
    end
    puts "Done !!!!!"
  end
end
