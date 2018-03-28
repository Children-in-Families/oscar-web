namespace :client_district_changelog do
  desc 'Update client district changelog'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      PaperTrail::Version.where(item_type: 'Client', event: 'destroy').each do |version|
        if version.object.present?
          obj = version.object.gsub(/^district:/, 'archive_district:')
          version.update(object: obj)
        end
      end
    end
  end
end
