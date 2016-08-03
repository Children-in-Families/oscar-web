namespace :agencies do
  desc 'Import all agencies'
  task import: :environment do
    sheet_name = 'Agency'
    import     = Importer::Import.new(sheet_name)
    import.agencies
  end
end
