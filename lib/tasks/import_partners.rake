namespace :partners do
  desc 'Import KC Management'
  task import: :environment do
    sheet_name = 'Referral %2F Ongoing Partners'
    import     = Importer::Import.new(sheet_name)

    import.partners
  end
end
