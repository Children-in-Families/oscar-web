namespace :referral_sources do
  desc 'Import all referral sources'
  task import: :environment do
    sheet_name = 'Referral Source'
    import     = Importer::Import.new(sheet_name)
    import.referral_sources
  end
end
