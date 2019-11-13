namespace :change_client_province do
  desc 'Correct client province to the right province, change province country and delete province'
  task update: :environment do

    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      current_org = Organization.current.short_name
      Client.where.not(birth_province_id: nil).each do |client|
        Organization.switch_to 'shared'
        if client.birth_province_id == 345
          shared_client = SharedClient.find_by(slug: client.slug)
          shared_client.update(birth_province_id: 246)
        elsif client.birth_province_id == 35
          shared_client = SharedClient.find_by(slug: client.slug)
          shared_client.update(birth_province_id: 15)
        elsif client.birth_province_id == 55
          shared_client = SharedClient.find_by(slug: client.slug)
          shared_client.update(birth_province_id: 142)
        end
        Organization.switch_to current_org
      end
    end
    puts 'change province done!!'
    Organization.switch_to 'shared'
    myanmar_province = Province.find_by(id: 101)
    myanmar_province.update(country: 'myanmar') if myanmar_province.country == 'thailand'
    myawaddy_province = Province.find_by(id: 52)
    myawaddy_province.update(country: 'myanmar') if myawaddy_province.country == 'thailand'
    burmese_province = Province.find_by(id: 99)
    burmese_province.update(country:'myanmar') if burmese_province.country == 'thailand'
    Province.find_by(id: 345).destroy
    Province.find_by(id: 35).destroy
    Province.find_by(id: 55).destroy
    Province.find_by(id: 77).destroy
    puts 'destroy province done !!'
  end
end
