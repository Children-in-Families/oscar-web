namespace :client_donor_as_sponsors do
  desc 'update all clients school grade'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      clients = Client.where.not(donor_id: nil)
      clients.each do |client|
        client.sponsors.find_or_create_by(donor_id: client.donor_id)
      end
    end
  end
end
