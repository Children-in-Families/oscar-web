namespace :scco do
  desc 'Import all SCCO clients and related data'
  task import: :environment do
    Organization.find_or_create_by(full_name: 'Stellar Child Care Organization', short_name: 'scc', logo: File.open(Rails.root.join('app/assets/images/SCCO.jpg')))
    Organization.switch_to 'scc'

    import     = SccImporter::Import.new('users')
    import.users

    import     = SccImporter::Import.new('clients')
    import.clients
  end
end
