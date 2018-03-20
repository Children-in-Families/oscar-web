namespace :update_client_exit_circumstance do
  desc 'Update client exit circumstance when accepted or rejected'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      rejected_clients = Client.where(state: 'rejected')
      accepted_clients = Client.where(state: 'accepted', status: 'Exited')

      rejected_clients.each do |client|
        client.exit_date         = client.initial_referral_date + 14
        client.exit_circumstance = 'Rejected Referral'
        client.save(validate: false)
      end

      accepted_clients.each do |client|
        client.exit_circumstance = 'Exited Client'
        client.save(validate: false)
      end

    end
  end
end
