namespace :exited_client_case_worker do
  desc "Find exited clients and distatach case worker"
  task disattach: :environment do
    Organization.without_shared.pluck(:short_name).each do |short_name|
      Apartment::Tenant.switch short_name
      puts "Starting Teannt #{short_name}"
      Client.joins(:case_worker_clients).where(status: 'Exited').distinct.each do |client|
        client.case_worker_clients.destroy_all
        puts "Remove client: #{client.slug}"
      end
    end
  end

end
