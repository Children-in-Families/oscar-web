namespace :mother_heart do
  desc 'Import new clients for mother\'s heart'
  task import_new_client: :environment do

    Organization.switch_to 'mho'

    Client.destroy_all

    import     = MotherHeartNewClientImporter::Import.new('Client')
    import.clients
  end
end
