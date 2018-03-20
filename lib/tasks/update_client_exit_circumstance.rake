namespace :update_client_exit_circumstance do
  desc 'Update client exit_circumstance when state is rejected'
  task update_on_state: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      clients = Client.where(state: 'rejected', status: 'Exited')

      clients.each do |client|
        exit_circumstance = 'Rejected Referral'
        client.update(exit_circumstance: exit_circumstance)
      end
    end
  end

  desc 'Update client exit_circumstance when status is exited'
  task update_on_status: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      clients = Client.where(state: 'accepted', status: 'Exited')

      clients.each do |client|
        exit_circumstance = 'Exited Client'
        client.update(exit_circumstance: exit_circumstance)
      end
    end
  end

end
