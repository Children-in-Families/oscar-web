namespace :ahc do
  desc "Import all Anghor Hospital For Children clients and related data"
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'ahc', full_name: "Angkor Hospital For Children", logo: File.open(Rails.root.join('app/assets/images/ahc-logo.png')))
    Organization.switch_to org.short_name

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import = AhcImporter::Import.new('Users')
    import.users

    import = AhcImporter::Import.new('Donors')
    import.donors

    import = AhcImporter::Import.new('Clients')
    import.clients
  end
end
