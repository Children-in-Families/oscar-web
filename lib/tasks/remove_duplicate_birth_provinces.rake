namespace :remove_duplicate_birth_provinces do
  desc 'remove duplicate birth provinces in shared tenant'
  task start: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name
      Client.where.not(birth_province_id: nil).each do |client|
        org = Organization.current
        province_id = client.birth_province_id

        Organization.switch_to 'shared'

        province = Province.country_is('cambodia').find_by(id: province_id)
        next if province.nil?
        province_name = province.name

        used_provinces = Province.country_is('cambodia')

        if province_name.include?('Banteay Meanchay')
          province_id = used_provinces.where('name ilike ? ', '%Banteay Meanchey%').first.id
        elsif province_name.include?('Mondulkiri')
          province_id = used_provinces.where('name ilike ? ', '%Mondul Kiri%').first.id
        elsif province_name.include?('Oddar Meanchay')
          province_id = used_provinces.where('name ilike ? ', '%Oddar Meanchey%').first.id
        elsif province_name.include?('Sihannouk')
          province_id = used_provinces.where('name ilike ? ', '%Sihanouk%').first.id
        elsif province_name.include?('Ratanakiri')
          province_id = used_provinces.where('name ilike ? ', '%Ratanak Kiri%').first.id
        elsif province_name.include?('Seam Reap') || province_name.include?('Siem Reap')
          province_id = used_provinces.where('name ilike ? ', '%Siemreap%').first.id
        elsif province_name.include?('បៃលិន') || province_name.include?('Siem Reap')
          province_id = used_provinces.where('name ilike ? ', '%ប៉ៃលិន%').first.id
        elsif province_name.include?('ត្បួងឃ្មុំ') || province_name.include?('Siem Reap')
          province_id = used_provinces.where('name ilike ? ', '%ត្បូងឃ្មុំ%').first.id
        end

        Organization.switch_to org.short_name
        client.birth_province_id = province_id
        if client.birth_province_id_changed?
          puts client.slug
        end
        client.save(validate: false)
      end
    end

    Organization.switch_to 'shared'

    wrong_provinces = Province.country_is('cambodia').where('name iLike ? or name iLike ? or name iLike ? or name iLike ? or name iLike ? or name iLike ? or name iLike ? or name iLike ? or name iLike ?', '%ត្បួងឃ្មុំ%', '%បៃលិន%', '%Banteay Meanchay%', '%Mondulkiri%', '%Oddar Meanchay%', '%Sihannouk%', '%Ratanakiri%', '%Seam Reap%', '%Siem Reap%')
    wrong_provinces.destroy_all

    Organization.all.each do |org|
      Organization.switch_to org.short_name
      provinces = Province.where('name iLike ? ', '%Oddar%')
      if provinces.any?
        # some name might contain non blank space
        provinces.update_all(name: 'ឧត្ដរមានជ័យ / Oddar Meanchey')
      end
    end
  end
end
