namespace :mission_worldwide do
  desc 'Import all Mission Worldwide clients and related data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'tmw', full_name: 'The Mission Worldwide', country: 'cambodia', logo: File.open(Rails.root.join('app/assets/images/TMWUK.png')))
    Organization.switch_to org.short_name
    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['districts:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
    Rake::Task['communes_and_villages:import'].invoke
    Rake::Task['communes_and_villages:import'].reenable

    import     = TmwImporter::Import.new('Users')
    import.users

    import     = TmwImporter::Import.new('Client')
    import.clients
  end
end
