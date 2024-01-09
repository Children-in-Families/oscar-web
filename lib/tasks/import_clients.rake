namespace :clients do
  desc 'Import all clients'
  task :import, [:short_name, :file_name, :domain] => [:environment] do |task, args|
    path = Rails.root.join("vendor/data/organizations/#{args.file_name}")
    Apartment::Tenant.switch args.short_name
    import = ClientsImporter::Import.new(path, { users: 'Users or Staff', clients: 'Client', donors: 'Donors' }, args.domain)
    import.import_all
  end
end
