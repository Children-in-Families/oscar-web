namespace :auscam do
  desc 'Import all Auscam clients and related data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'auscam', full_name: "Auscam Freedom Project", logo: File.open(Rails.root.join('app/assets/images/auscam.png')))
    # Organization.switch_to org.short_name
    Organization.switch_to 'auscam'

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import     = MoveDistrict::Import.new('auscam')
    import.districts

    import     = AuscamImporter::Import.new('Users')
    import.users

    import     = AuscamImporter::Import.new('Client')
    import.clients
  end
end
