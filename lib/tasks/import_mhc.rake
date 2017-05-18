namespace :mhc do
  desc "Import Mother's Heart Cambodia users"
  task import: :environment do
    Organization.switch_to 'mhc'
    import = MhcImporter::Import.new('Clients')
    import.clients
  end
end
