namespace :duplicate_checker_field do
  desc 'Update duplicate checker field in shared client'
  task update: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name
      Client.all.each do |client|
        client.create_or_update_shared_client
      end
    end
  end
end
