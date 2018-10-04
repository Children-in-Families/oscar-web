namespace :remove_province do
  desc 'Remove Poipet, Community, Other and Outside Cambodia in Province'
  task start: :environment do
    province_names = ['បោយប៉ែត/Poipet', 'Community', 'Other / ផ្សេងៗ', 'នៅ​ខាង​ក្រៅ​កម្ពុជា / Outside Cambodia']
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      Province.where(name: province_names).each do |province|
        Client.where(province_id: province.id).each do |client|
          client.province_id = nil
          client.save(validate: false)
        end

        Client.where(birth_province_id: province.id).each do |client|
          client.birth_province_id = nil
          client.save(validate: false)
        end

        province.families.each do |family|
          family.province_id = nil
          family.save(validate: false)
        end

        province.partners.each do |partner|
          partner.province_id = nil
          partner.save(validate: false)
        end

        province.cases.each do |client_case|
          client_case.province_id = nil
          client_case.save(validate: false)
        end

        province.users.each do |user|
          user.province_id = nil
          user.save(validate: false)
        end

        province.government_forms.each do |government_form|
          government_form.province_id = nil
          government_form.save(validate: false)
        end

        province.delete
      end
    end

    Organization.switch_to 'shared'
    provinces = Province.where(name: province_names)
    SharedClient.where(birth_province_id: provinces.ids).each do |shared_client|
      shared_client.birth_province_id = nil
      shared_client.save(validate: false)
    end
    provinces.destroy_all
  end
end
