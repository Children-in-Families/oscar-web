namespace :scc do
  desc 'Import all SCCO clients and related data'
  task import: :environment do
    # Organization.create_and_build_tanent(full_name: 'Stellar Child Care Organization', short_name: 'scc', logo: File.open(Rails.root.join('app/assets/images/SCCO.jpg')))
    Organization.switch_to 'scc'

    import     = SccImporter::Import.new('Case Workers')
    import.users

    import     = SccImporter::Import.new('Clients')
    import.clients
  end
end
