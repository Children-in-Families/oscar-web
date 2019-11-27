namespace :birth_province_correction_v3 do
  desc 'Correct client birth provinces v3'
  task start: :environment do

    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      Client.where.not(birth_province_id: nil).each do |client|
        Organization.switch_to 'shared'
        begin
          not_cambodia_province = Province.where(country: 'cambodia').where.not("name iLIKE?", "%/%").ids
          client_birth_province_id = client.birth_province_id
          client_slug = client.slug
          if not_cambodia_province.include?(client_birth_province_id)
            shared_client = SharedClient.find_by(slug: client_slug)
            shared_birth_province_id = Province.find_by(id: client_birth_province_id).try(:id)
            shared_client.update(birth_province_id: shared_birth_province_id) if shared_client
          end
          Organization.switch_to org.short_name
        rescue Exception => e
          binding.pry
        end
      end
    end
    puts 'change province done!!'
    Organization.switch_to 'shared'

    Province.where(country: 'cambodia').where.not("name iLIKE?", "%/%").delete_all
    puts 'destroy non Cambodia province done !!'
  end
end
