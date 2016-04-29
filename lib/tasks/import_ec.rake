namespace :ec do
  desc 'Import Province'
  task import: :environment do
    sheet_name = 'EC Child Referral List'
    import     = Importer::Import.new(sheet_name)

    import.ec
  end
end
