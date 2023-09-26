namespace :duplicate_checker_field do
  desc 'Update duplicate checker field in shared client'
  task :update, [:short_name] => :environment do |task, args|
    Organization.switch_to args.short_name
    Client.all.each do |client|
      client.create_or_update_shared_client
    end
  end

  desc 'Update duplicate checker field in all clients'
  task :update_all => :environment do
    Organization.without_shared.where(onboarding_status: 'completed').each do |organization|
      Organization.switch_to organization.short_name

      Client.ids.each do |client_id|
        DuplicateCheckerWorker.perform_async(client_id, organization.short_name)
      end
    end
  end
end
