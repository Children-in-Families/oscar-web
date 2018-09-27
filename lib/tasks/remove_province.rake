namespace :remove_province do
  desc 'Remove Poipet, Community, Other and Outside Cambodia in Province'
  task start: :environment do
    Organization.all.each do |org|
      provinces = ['បោយប៉ែត/Poipet', 'Community', 'Other / ផ្សេងៗ', 'នៅ​ខាង​ក្រៅ​កម្ពុជា / Outside Cambodia']
      Organization.switch_to org.short_name
      Province.where(name: provinces).each do |province|
        province.clients.each do |client|
          client.province_id = nil
          client.save
        end
        province.destroy
      end
    end
  end
end
