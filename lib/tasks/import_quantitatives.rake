namespace :quantitatives do
  desc 'Import Province'
  task import: :environment do
    path       = 'vendor/data/quantitative_types_and_data.xlsx'
    sheet_name = 'Quantitative'
    import     = Importer::Import.new(sheet_name, path)

    import.quantitatives
  end
end
