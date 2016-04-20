namespace :kc_managements do
  desc 'Import KC Management'
  task import: :environment do
    sheet_name = 'KC Mgmt.'
    import     = Importer::Import.new(sheet_name)

    import.kc_managements
  end
end
