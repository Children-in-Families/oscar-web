namespace :update_client_exit_circumstance do
  desc 'Update client exit circumstance when accepted or rejected'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      rejected_clients = Client.where(state: 'rejected')
      accepted_clients = Client.where(state: 'accepted', status: 'Exited')

      rejected_clients.each do |client|
        if client.exit_date.nil?
          client.exit_date = client.initial_referral_date + 14
        end
        client.exit_circumstance = 'Rejected Referral'
        client.status            = 'Exited'
        client.save(validate: false)
      end

      accepted_clients.each do |client|
        client.exit_circumstance = 'Exited Client'
        if client.exit_date.nil?
          client.exit_date = client.initial_referral_date + 14
        end
        client.save(validate: false)
      end
    end
  end
end
