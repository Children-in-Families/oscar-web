namespace :quarterly_reports do
  desc 'Import Province'
  task import: :environment do
    sheet_name = 'Quarterly Reports'
    import     = Importer::Import.new(sheet_name)

    import.quarterly_reports
  end
end
