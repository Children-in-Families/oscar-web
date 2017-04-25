namespace :cct do
  desc 'Import all CCT clients and related data'
  task import: :environment do
    cct_org = Organization.find_by(short_name: 'cct')
    Organization.switch_to cct_org.short_name

    import     = CctImporter::Import.new('users')
    import.users

    import     = CctImporter::Import.new('clients')
    import.clients
  end
end
