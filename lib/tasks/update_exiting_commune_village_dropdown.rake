namespace :update_commune_village do
  desc 'update commune village data from freetext to drop down'
  task update: :environment do
    Organization.where.not(short_name: 'shared').each do |org|
      Organization.switch_to org.short_name

      [[Client.all, 'Client'], [Family.all, 'Family']].each do |all_objects, klass_name|
        all_objects.each do |object|
          province_id = object.province_id
          district_id = object.district_id
          old_commune = object.old_commune
          old_village = object.old_village

          next if province_id.nil? || district_id.nil? || old_commune.blank?

          commune_id = District.find(district_id).communes.where('name_en iLIKE :name OR name_kh iLIKE :name', { name: old_commune }).first.try(:id)
          object.commune_id = commune_id

          if old_village.present? && commune_id.present?
            village_id = Commune.find(commune_id).villages.where('name_en iLIKE :name OR name_kh iLIKE :name', { name: old_village }).first.try(:id)
            object.village_id = village_id
          end
          object.save!(validate: false)
        end
        puts "#{org.short_name}: #{klass_name}, finish!"
      end

      setting     = Setting.first
      province_id = setting.province_id
      district_id = setting.district_id
      old_commune = setting.old_commune

      next if province_id.nil? || district_id.nil? || old_commune.blank?
      commune_id = District.find(district_id).communes.where('name_en iLIKE :name OR name_kh iLIKE :name', { name: old_commune }).first.try(:id)
      setting.commune_id = commune_id
      setting.save!(validate: false)

      puts  "#{org.short_name}" + ': Setting, finish!'
    end
  end
end
