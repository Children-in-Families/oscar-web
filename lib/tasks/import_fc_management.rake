namespace :fc_managements do
  desc 'Import FC Management'
  task import: :environment do
    sheet_name = 'FC Mgmt'
    import     = Importer::Import.new(sheet_name)

    import.fc_managements
  end
end
