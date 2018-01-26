namespace :agh do
  desc 'Import A Greater Hope data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'agh', full_name: "A Greater Hope", logo: File.open(Rails.root.join('app/assets/images/agh.jpg')))
    Organization.switch_to org.short_name

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import = MoveDistrict::Import.new
    import.districts

    import = AghImporter::Import.new('Families')
    import.families

    import = AghImporter::Import.new('Donors')
    import.donors

    import = AghImporter::Import.new('Case Workers')
    import.users

    import = AghImporter::Import.new('Clients')
    import.clients
  end
end
