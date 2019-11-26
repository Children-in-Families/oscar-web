namespace :birth_province_missing do
  desc "Restoring missing client birth_province"
  task restore: :environment do
    Organization.pluck(:short_name).each do |short_name|
      province_ids = []
      client_ids = []
      next if short_name == 'shared'
      Organization.switch_to short_name
      clients = Client.where("clients.birth_province_id IS NOT NULL AND clients.id NOT IN (SELECT id from shared.provinces)").order(:id)
      provinces_clients  = clients.pluck(:birth_province_id, :id).to_h
      Organization.switch_to 'shared'
      provinces = PaperTrail::Version.where(item_type: 'Province', event: 'create').where(item_id: provinces_clients.keys).map{|version| [version.item_id, version.changeset['name'].last] }
      provinces.map do |province|
        province_name = province.last.split('/').first
        province_name == "ឧត្តរមានជ័យ " ? "ឧត្ដរមានជ័យ" : province_name

        found_province = Province.where("name iLIKE ?", "#{province_name}%/%")
        if found_province.first.nil?
          province_name = province.last.split('/').last
          province_name = province_name == " Oddar Meanchay" ? " Oddar Meanchey" : province_name
          province_name = province_name == "Communex" ? "Kampong Cham" : province_name
          province_name = province_name == ' Siem Reap' ? "Siemreap" : province_name
          province_name = province_name == ' Preah Sihannouk' ? "Preah Sihanouk" : province_name
          province_name = province_name == 'Poipet' ? "Banteay Meanchey" : province_name
          found_province = Province.where("name iLIKE ?", "%#{province_name}")
        end
        if found_province.first.nil?
          found_province = Province.where(name: province_name)
        end
        puts "#{short_name}: '#{province_name}'"
        next if ['Community', ' ផ្សេងៗ', ' Outside Cambodia', 'Thailand', 'Burmese', 'Myawaddy'].include?(province_name)
        province_ids << [province.first, [found_province.first.id, provinces_clients[province.first]]]
      end
      Organization.switch_to short_name
      province_hash = province_ids.to_h

      Client.where(id: provinces_clients.values).order(:id).each do |client|
        the_province = province_hash[client.birth_province_id]
        next if the_province.nil?
        client.update_column(:birth_province_id, the_province.first)
      end

      client_id_slug = Client.where(id: provinces_clients.values).pluck(:id, :slug, :birth_province_id)
      Organization.switch_to 'shared'
      client_id_slug.each do |id, slug, birth_province_id|
        shared_client = SharedClient.find_by(slug: slug)
        next if shared_client.nil?
        shared_client.birth_province_id = birth_province_id
        shared_client.save!
      end
    end
  end
end
