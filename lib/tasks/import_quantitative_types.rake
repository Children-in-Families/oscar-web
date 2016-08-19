namespace :quantitative_types do
  desc 'Import all quantitative types'
  task import: :environment do
    sheet_name = 'Quantitative Type'
    import     = Importer::Import.new(sheet_name)
    import.quantitative_types
  end
end
