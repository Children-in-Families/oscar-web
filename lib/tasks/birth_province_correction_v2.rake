namespace :birth_province_correction_v2 do
  desc 'Correct client birth provinces v2'
  task start: :environment do

    Organization.where.not(short_name: ['shared', 'spo', 'kmo']).each do |org|
      Organization.switch_to org.short_name
      current_org = Organization.current
      slugs= PaperTrail::Version.where(item_type: 'Client').map{|a| (a.item.slug if a.changeset[:birth_province_id].present? && a.changeset[:birth_province_id].last == nil && a.item.present?)}.uniq
      Client.where(birth_province_id: nil, slug: slugs).each do |client|
        p_id = client.versions.where(event: 'update').map{|a| (a.changeset[:birth_province_id].first if a.changeset[:birth_province_id].present? && a.changeset[:birth_province_id].last == nil && a.item.present?)}.uniq.reject(&:nil?).last

        province_name = Province.find_by(id: p_id).try(:name)
        Organization.switch_to 'shared'
        shared_birth_province_id = Province.find_by(name: province_name).try(:id)
        Organization.switch_to current_org.short_name
        client.birth_province_id = shared_birth_province_id
        client.save(validate: false)
      end
    end
  end
end
