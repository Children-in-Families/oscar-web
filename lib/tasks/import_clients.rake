namespace :clients do
  desc 'Import all clients'
  task import: :environment do
    path = Rails.root.join('vendor/data/organizations/chab_dai_data.xlsx')
    Apartment::Tenant.switch 'cdc'
    import = ClientsImporter::Import.new(path, { users: 'Users or Staff', clients: 'Client', donors: 'Donors' })
    import.import_all
  end
end
