namespace :exited_client_status do
  desc 'Correct Exited client status'
  task :correct, [:short_name] => :environment do |task, args|
    if args.short_name
      Apartment::Tenant.switch args.short_name
      clients = Client.where(status: 'Accepted')
      update_wrong_status(clients)
    else
      Organization.without_shared.oscar.each do |org|
        Apartment::Tenant.switch org.short_name
        clients = Client.where(status: 'Accepted')
        update_wrong_status(clients)
      end
    end
  end
end

def update_wrong_status(clients)
  clients.joins(:exit_ngos).each do |client|
    last_exited_ngo = client.exit_ngos.last
    next unless last_exited_ngo

    if client.client_enrollments.last
      if last_exited_ngo.created_at > (client.client_enrollments.last.created_at)
        client.update_columns(status: 'Exited')
        puts "====================================#{client.slug}=========================================="
      end
    elsif client.enter_ngos.last
      if last_exited_ngo.created_at > (client.enter_ngos.last.created_at)
        client.update_columns(status: 'Exited')
        puts "====================================#{client.slug}=========================================="
      end
    end
  end
end
