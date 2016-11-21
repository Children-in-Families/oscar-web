namespace :clients do
  desc 'Import all clients'
  task import: :environment do
    sheet_name = 'Sheet1'
    import     = Importer::Import.new(sheet_name)
    import.clients
  end
end
