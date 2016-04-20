namespace :fc_families do
  desc 'Import KC Family'
  task import: :environment do
    sheet_name = 'FC Family Info'
    import     = Importer::Import.new(sheet_name)

    import.fc_families
  end
end
