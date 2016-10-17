namespace :quantitative_cases do
  desc 'Import all quantitative cases'
  task import: :environment do
    sheet_name = 'Quantitative Case'
    import     = Importer::Import.new(sheet_name)
    import.quantitative_cases
  end
end
