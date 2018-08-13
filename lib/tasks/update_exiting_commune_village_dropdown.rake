namespace :update_commune_village do
  desc 'update commune village data from freetext to drop down'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      Client.all.each do |client|
        province_id = client.province_id
        district_id = client.district_id
        old_commune = client.old_commune
        old_village = client.old_village
        commune_id  = nil
        village_id  = nil
        communes    = []
        villages    = []

        if district_id.present?
          communes = Commune.where(district_id: district_id)
          commune_id = communes.where(name_en: old_commune.squish).or(communes.where(name_kh: old_commune.squish)).first.try(:id) if old_commune.present?
          client.commune_id = commune_id
        else
          communes = Commune.all
          commune_id = communes.where(name_en: old_commune.squish).or(communes.where(name_kh: old_commune.squish)).first.try(:id) if old_commune.present?
          if commune_id.present?
            district_id = Commune.find(commune_id).district_id
            client.district_id  = district_id
          end
          client.commune_id = commune_id
        end
        client.save!(validate: false)

        if commune_id.present?
          villages = Village.where(commune_id: commune_id)
          village_id = villages.where(name_en: old_village.squish).or(villages.where(name_kh: old_village.squish)).first.try(:id) if old_village.present?
          client.village_id = village_id
        else
          villages = Village.all
          village_id = villages.where(name_en: old_village.squish).or(villages.where(name_kh: old_village.squish)).first.try(:id) if old_village.present?
          if village_id.present?
            commune_id = Village.find(village_id).commune_id
            client.commune_id  = commune_id
          end
          client.village_id = village_id
        end
        client.save!(validate: false)
      end

      puts "#{org.short_name}" + ': Clients, finish!'

      Family.all.each do |family|
        province_id = family.province_id
        district_id = family.district_id
        old_commune = family.old_commune
        old_village = family.old_village
        commune_id  = nil
        village_id  = nil
        communes    = []
        villages    = []

        if district_id.present?
          communes = Commune.where(district_id: district_id)
          commune_id = communes.where(name_en: old_commune.squish).or(communes.where(name_kh: old_commune.squish)).first.try(:id) if old_commune.present?
          family.commune_id = commune_id
        else
          communes = Commune.all
          commune_id = communes.where(name_en: old_commune.squish).or(communes.where(name_kh: old_commune.squish)).first.try(:id) if old_commune.present?
          if commune_id.present?
            district_id = Commune.find(commune_id).district_id
            family.district_id  = district_id
          end
          family.commune_id   = commune_id
        end

        family.save!(validate: false)

        if commune_id.present?
          villages = Village.where(commune_id: commune_id)
          village_id = villages.where(name_en: old_village.squish).or(villages.where(name_kh: old_village.squish)).first.try(:id) if old_village.present?
          family.village_id = village_id
          family.save!(validate: false)
        else
          villages = Village.all
          village_id = villages.where(name_en: old_village.squish).or(villages.where(name_kh: old_village.squish)).first.try(:id) if old_village.present?
          if village_id.present?
            commune_id = Village.find(village_id).commune_id
            family.commune_id  = commune_id
          end
          family.village_id = village_id
        end
        family.save!(validate: false)
      end

      puts  "#{org.short_name}" + ': Families, finish!'

      Setting.all.each do |setting|
        province_id = setting.province_id
        district_id = setting.district_id
        old_commune = setting.old_commune
        commune_id  = nil
        communes    = []

        if district_id.present?
          communes = Commune.where(district_id: district_id)
          commune_id = communes.where(name_en: old_commune.squish).or(communes.where(name_kh: old_commune.squish)).first.try(:id) if old_commune.present?
          setting.commune_id = commune_id
        else
          communes = Commune.all
          commune_id = communes.where(name_en: old_commune.squish).or(communes.where(name_kh: old_commune.squish)).first.try(:id) if old_commune.present?
          if commune_id.present?
            district_id = Commune.find(commune_id).district_id
            setting.district_id  = district_id
          end
          setting.commune_id = commune_id
        end
        setting.save!(validate: false)
      end

      puts  "#{org.short_name}" + ': Setting, finish!'

    end

  end
end
