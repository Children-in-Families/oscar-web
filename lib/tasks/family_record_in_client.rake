namespace :family_record_in_client do
  desc 'Update family record in client'
  task import: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Family.all.each do |family|
        family.children.each do |child|
          client = Client.find_by(id: child) 
          next if client.family_ids.include?(family.id)
          client.families << family
          client.families.uniq
          client.save(validate: false)
        end
      end
    end
  end
end
