namespace :cfi do
  desc 'Import all CFI clients and related data'
  task import: :environment do
    cfi_org = Organization.find_by(short_name: 'cfi')
    Organization.switch_to cfi_org.short_name

    import     = CfiImporter::Import.new('users')
    import.users

    import     = CfiImporter::Import.new('clients')
    import.clients
  end
end
