namespace :safe_haven do
  desc 'Import all Safe Haven clients and related data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'sho', full_name: "Safe Haven", logo: File.open(Rails.root.join('app/assets/images/haven.png')))
    # Organization.switch_to org.short_name
    Organization.switch_to 'sho'

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import     = MoveDistrict::Import.new('sho')
    import.districts

    import     = SafeHavenImporter::Import.new('Users')
    import.users

    import     = SafeHavenImporter::Import.new('Client')
    import.clients
  end
end
