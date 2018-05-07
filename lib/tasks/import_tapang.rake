namespace :tapang do
  desc "Import all M'Lop Tapang clients and related data"
  task import: :environment do
    Organization.switch_to 'mtp'

    paths = ['vendor/data/mtp1.xlsx', 'vendor/data/mtp2.xlsx', 'vendor/data/mtp3.xlsx']

    paths.each do |path|
      import     = TapangImporter::Import.new('Referral', path)
      import.referral_sources

      import     = TapangImporter::Import.new('Agency', path)
      import.agencies

      import     = TapangImporter::Import.new('Family', path)
      import.families

      import     = TapangImporter::Import.new('Users', path)
      import.users

      import     = TapangImporter::Import.new('Client', path)
      import.clients
    end

  end
end
