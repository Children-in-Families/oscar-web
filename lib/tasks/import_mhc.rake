namespace :mhc do
  desc "Import Mother's Heart Cambodia Clients"
  task import: :environment do
    Organization.switch_to 'mhc'
    # import = MhcImporter::Import.new('Case Workers')
    # import.users

    import = MhcImporter::Import.new('Clients')
    import.update
  end
end
