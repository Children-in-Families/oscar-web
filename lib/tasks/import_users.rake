namespace :users do
  desc 'Import client/staff'
  task import: :environment do
    sheet_name = 'Staff Info'
    import     = Importer::Import.new(sheet_name)

    import.users
  end
end
