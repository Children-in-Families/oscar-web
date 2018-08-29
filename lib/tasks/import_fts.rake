namespace :fts do
  desc "Import all Free To Shine and related data"
  task import: :environment do
    Organization.create_and_build_tanent(short_name: 'fts', full_name: 'Free To Shine', logo: File.open(Rails.root.join('app/assets/images/freetoshine_logo.jpg')))
    Organization.switch_to 'fts'
    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['districts:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
    Rake::Task['db:seed'].invoke

    import = FtsImporter::Import.new('Users')
    import.users

    import = FtsImporter::Import.new('Donors')
    import.donors

    import = FtsImporter::Import.new('Clients')
    import.clients
  end
end
