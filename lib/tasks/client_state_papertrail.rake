namespace :client_state_papertrail do
  desc 'Update client state papertrail'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      PaperTrail::Version.where(item_type: 'Client').each do |version|
        if version.object.present?
          obj = version.object.gsub(/^state:/, 'archive_state:')
          version.update(object: obj)
        end

        if version.object_changes.present?
          obj = version.object_changes.gsub(/^state:/, 'archive_state:')
          version.update(object_changes: obj)
        end
      end
    end
  end
end
