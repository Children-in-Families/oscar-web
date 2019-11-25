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
    Province.find_by(id: 345).try(:destroy)
    Province.find_by(id: 35).try(:destroy)
    Province.find_by(id: 55).try(:destroy)
    #Malaysia
    Province.find_by(id: 77).try(:destroy)
    #Thailand
    Province.find_by(id: 93).try(:destroy)
    #Myanmar
    Province.find_by(id: 101).try(:destroy)
    #Burmese
    Province.find_by(id: 99).try(:destroy)
    #Myawaddy
    Province.find_by(id: 52).try(:destroy)
    puts 'destroy province done !!'
  end
end
