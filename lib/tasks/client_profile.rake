namespace :client_profile do
  desc 'recreate profile versions'
  task update: :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Client.all.each do |client|
        client.profile.recreate_versions!
      end
    end
  end
end
