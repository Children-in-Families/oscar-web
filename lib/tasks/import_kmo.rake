namespace :kmo do
  desc 'Import all Kinnected Myanmar clients and related data'
  task import: :environment do
    kmo_org = Organization.find_by(short_name: 'kmo')
    Organization.switch_to kmo_org.short_name

    import     = KmoImporter::Import.new('Provinces')
    import.provinces

    import     = KmoImporter::Import.new('Case Workers')
    import.users

    import     = KmoImporter::Import.new('Clients')
    import.clients
  end
end
