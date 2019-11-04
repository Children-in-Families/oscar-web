namespace :birth_province_correction_v3 do
  desc 'Correct client birth provinces v3'
  task start: :environment do

    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      current_org = Organization.current.short_name
      Client.where.not(birth_province_id: nil).each do |client|
        Organization.switch_to 'shared'
        not_cambodia_province = Province.where(country: 'cambodia').where.not("name iLIKE?", "%/%").ids
        client_birth_province_id = client.birth_province_id
        if not_cambodia_province.include?(client_birth_province_id)
          client_slug = client.slug
          shared_client = SharedClient.find_by(slug: client_slug)
          shared_client_province = Province.find_by(id: client_birth_province_id).try(:name)
          shared_birth_province_id = Province.find_by(name: shared_client_province).try(:id)
          shared_client.update(birth_province_id: shared_birth_province_id)
          Organization.switch_to current_org
        end
      end
    end
  end
end
