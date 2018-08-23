namespace :holt do
  desc 'Import Holt data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'holt', full_name: "Holt International Cambodia", logo: File.open(Rails.root.join('app/assets/images/holt.jpg')))
    Organization.switch_to org.short_name

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import = MoveDistrict::Import.new
    import.districts

    import = HoltImporter::Import.new('Families')
    import.families

    import = HoltImporter::Import.new('Case Workers')
    import.users

    import = HoltImporter::Import.new('Clients')
    import.clients
  end
end
