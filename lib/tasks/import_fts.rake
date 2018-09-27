namespace :fts do
  desc "Import all Free To Shine and related data"
  task import: :environment do
    Organization.switch_to 'fts'

    import = FtsImporter::Import.new('Clients', 'vendor/data/fts.xlsx')
    import.clients

    import = FtsImporter::Import.new('Donors', 'vendor/data/fts.xlsx')
    import.donors

    import = FtsImporter::Import.new('Case Load OSCaR', 'vendor/data/VichhekaCaseLoadOSCaR.xlsx')
    import.update_case_work
  end
end
