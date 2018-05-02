namespace :tapang do
  desc "Import all M'Lop Tapang clients and related data"
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'mtp', full_name: "M'Lop Tapang", logo: File.open(Rails.root.join('app/assets/images/mtp.png')))
    Organization.switch_to org.short_name

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    paths = ['vendor/data/mtp1.xlsx', 'vendor/data/mtp2.xlsx', 'vendor/data/mtp3.xlsx']


    import     = MoveDistrict::Import.new
    import.districts

    paths.each do |path|
      import     = TapangImporter::Import.new('Referral', path)
      import.referral_sources

      import     = TapangImporter::Import.new('Family', path)
      import.families

      import     = TapangImporter::Import.new('Users', path)
      import.users

      import     = TapangImporter::Import.new('Client', path)
      import.clients
    end

  end
end
