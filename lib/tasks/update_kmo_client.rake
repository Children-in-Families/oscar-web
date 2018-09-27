namespace :update_kmo_client do
  desc 'Update dates for kinnected(kmo) clients'
  task update: :environment do |task, args|
    Organization.switch_to 'kmo'

    client = ClientKmo::DataClient.new('Worksheet1')
    client.update
  end
end
