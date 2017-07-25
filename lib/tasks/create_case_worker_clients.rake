namespace :case_worker_client do
  desc 'Create case worker clients'
  task create: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Client.all.each do |client|
        client.case_worker_clients.find_or_create_by(user_id: client.user_id) if client.user_id.present?
      end
    end
  end
end
