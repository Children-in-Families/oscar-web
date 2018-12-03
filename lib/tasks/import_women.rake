namespace :women do
  desc 'Import all women data'
  task import: :environment do
    Organization.switch_to 'wmo'
    import     = WmoImporter::Import.new('Case Workers')
    import.users

    import     = WmoImporter::Import.new('Families')
    import.families

    import     = WmoImporter::Import.new('Clients')
    import.clients
  end
end
