namespace :client_commune_village_papertrail do
  desc 'Update client commune villiage papertrail'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      PaperTrail::Version.where(item_type: 'Client').each do |version|
        if version.object.present?
          obj = version.object.gsub(/^commune:/, 'old_commune:').gsub(/^village:/, 'old_village:')
          version.update(object: obj)
        end

        if version.object_changes.present?
          obj = version.object_changes.gsub(/^commune:/, 'old_commune:').gsub(/^village:/, 'old_village:')
          version.update(object_changes: obj)
        end
      end
    end
  end
end
