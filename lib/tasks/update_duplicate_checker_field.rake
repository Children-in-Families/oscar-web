namespace :duplicate_checker_field do
  desc 'Update duplicate checker field in shared client'
  task :update, [:short_name] => :environment do |task, args|
    Organization.switch_to args.short_name
    Client.all.each do |client|
      client.create_or_update_shared_client
    end
  end
end
