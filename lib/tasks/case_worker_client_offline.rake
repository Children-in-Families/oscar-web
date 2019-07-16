namespace :case_worker_client do
  desc 'create case worker clients in mongod'
  task create: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name
      Client.find_each do |client|
        begin
          client.create_case_worker_client_offline
        rescue => exception
          binding.pry
        end
      end
      puts "done #{org.short_name}"
    end
  end
end
