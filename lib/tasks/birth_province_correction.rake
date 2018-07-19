namespace :birth_province_correction do
  desc 'Correct client birth provinces'
  task start: :environment do

    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      current_org = Organization.current
      Client.where.not(birth_province_id: nil).each do |client|
        province_name = client.birth_province_name
        client_slug = client.slug
        Organization.switch_to 'shared'
        shared_client = SharedClient.find_by(slug: client_slug)
        shared_birth_province_id = Province.find_by(name: province_name).try(:id)
        shared_client.update(birth_province_id: shared_birth_province_id) if shared_client.present? && shared_birth_province_id.present?
        Organization.switch_to current_org.short_name
      end
    end
  end
end
