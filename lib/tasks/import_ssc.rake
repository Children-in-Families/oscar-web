namespace :ssc do
  desc 'Import all SSC clients and related data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'ssc', full_name: "Sunshine Cambodia", logo: File.open(Rails.root.join('app/assets/images/ssc.jpg')))
    Organization.switch_to org.short_name

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import     = MoveDistrict::Import.new
    import.districts

    import     = SscImporter::Import.new('Donors')
    import.donors

    import     = SscImporter::Import.new('Case Workers')
    import.users

    import     = SscImporter::Import.new('Clients')
    import.clients
  end
end
