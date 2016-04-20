namespace :kc_families do
  desc 'Import KC Family'
  task import: :environment do
    sheet_name = 'KC Family Info'
    import     = Importer::Import.new(sheet_name)

    import.kc_families
  end
end
