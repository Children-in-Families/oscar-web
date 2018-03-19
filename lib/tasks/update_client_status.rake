namespace :client_status do
  desc 'Update client status'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      exited_statuses = ['Independent - Monitored', 'Exited - Dead', 'Exited - Age Out', 'Exited Independent', 'Exited Adopted', 'Exited - Deseased', 'Exited Other']
      active_statuses = ['Active EC', 'Active FC', 'Active KC']

      Client.all.each do |client|
        if client.status.in? exited_statuses
          client.status = 'Exited'
          client.save(validate: false)
        elsif client.status.in? active_statuses
          client.status = 'Active'
          client.save(validate: false)
        end
      end
    end
  end
end
