namespace :update_commune_village do
  desc 'update commune village data from freetext to drop down'
  task update: :environment do
    Organization.all.each do |org|
      next if org.short_name != 'cif'
      Organization.switch_to org.short_name

      communes      = []
      villages      = []

      [[Client.all, 'Client'], [Family.all, 'Family']].each do |all_objects, klass_name|
        all_objects.each do |object|
          province_id = object.province_id
          district_id = object.district_id
          old_commune = object.old_commune
          old_village = object.old_village
          commune_id  = nil
          village_id  = nil

          next if (province_id.nil? && district_id.nil?) && (old_commune.blank? && old_village.present?) || (province_id.present? && district_id.present?) && (old_commune.blank? && old_village.blank?)

          if old_commune.present? && old_village.present?
            villages = Village.where(name_en: old_village.squish).or(Village.where(name_kh: old_village.squish))
            communes = Commune.where(name_en: old_commune.squish).or(Commune.where(name_kh: old_commune.squish))

            next if communes.blank? || villages.blank?

            if communes.ids.count == 1
              commune_id  = communes.ids.first
              district_id = Commune.find(commune_id).district_id
              village_id  = villages.where(commune_id: commune_id).first
              object.village_id  = village_id
              object.commune_id  = commune_id
              object.district_id = district_id
              if province_id.nil?
                province_id = District.joins(:object).find(district_id).province_id if district_id.present?
                object.province_id = province_id
              end
            else
              if district_id.present?
                commune = communes.where(district_id: district_id)
                if commune.blank?
                  district_id = object.province.districts.joins(:communes).where(communes: {id: communes.ids}).first.id
                  object.district_id = district_id
                end
                object.commune_id = commune_id
                object.village_id  = villages.where(commune_id: commune_id).first
                if province_id.nil?
                  province_id = District.find(district_id).province_id
                  object.province_id = province_id
                end
              else
                # object has no district attache
                district_id = object.province.districts.joins(:communes).where(communes: {id: communes.ids}).first.id
                object.district_id = district_id
              end
            end

            object.save!(validate: false)

          elsif province_id.present? && old_commune.present? && old_village.blank?
            communes = Commune.where(name_en: old_commune.squish).or(Commune.where(name_kh: old_commune.squish))
            next if communes.blank?
            district = object.province.districts.joins(:communes).where(communes: { id: communes.ids }).first
            if district.blank?
              district = District.joins(:communes).where(communes: { id: communes.ids }).first
              object.province_id = district.province_id
            end
            commune_id         = District.find(district.id).communes.where(id: communes.ids).first.try(:id)
            object.commune_id  = commune_id
            object.district_id = district.id
          elsif province_id.present? && old_commune.blank? && old_village.present?
            villages   = Village.where(name_en: old_village.squish).or(Village.where(name_kh: old_village.squish))

            next if villages.blank?

            district_id = object.province.districts.joins(communes: :villages).where(villages: { id: villages.ids }).first.id
            commune_id  = District.find(district_id).communes.joins(:villages).where(villages: { id: villages.ids }).first.id
            village_id  = Commune.find(commune_id).villages.where(id: villages.ids).first.try(:id)
            object.district_id = district_id
            object.commune_id  = commune_id
            object.village_id  = village_id
          end

          object.save!(validate: false)

        end
        puts "#{org.short_name}: #{klass_name}, finish!"
      end

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
          if province_id.nil?
            province_id = District.find(district_id).province_id
            family.province_id = province_id
          end
        else
          communes = Commune.all
          commune_id = communes.where(name_en: old_commune.squish).or(communes.where(name_kh: old_commune.squish)).first.try(:id) if old_commune.present?
          if commune_id.present?
            district_id = Commune.find(commune_id).district_id
            setting.district_id  = district_id
            if province_id.nil?
              province_id = District.find(district_id).province_id if district_id.present?
              family.province_id = province_id
            end
          end
          setting.commune_id = commune_id
        end
        setting.save!(validate: false)
      end

      puts  "#{org.short_name}" + ': Setting, finish!'
    end
  end
end
