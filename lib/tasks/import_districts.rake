namespace :districts do
  desc 'Import all districts'
  task import: :environment do
    sheet_name = 'District'
    import     = Importer::Import.new(sheet_name)
    import.districts
  end
end
