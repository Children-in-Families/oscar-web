namespace :hol do
  desc 'Import all Home of Love Cambodia clients, users, families and related data'
  task import: :environment do
    org = Organization.create_and_build_tenant(short_name: 'hol', full_name: 'Home of Love Cambodia', logo: File.open(Rails.root.join('app/assets/images/hol logo.jpg')))
    Organization.switch_to 'hol'
    Rake::Task['db:seed'].invoke
    Rake::Task['program_stream_service:create'].invoke
    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['districts:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
    Rake::Task['communes_and_villages:import'].invoke
    Rake::Task['communes_and_villages:import'].reenable

    import     = HolImporter::Import.new('Users')
    import.users

    import     = HolImporter::Import.new('Family')
    import.families

    import     = HolImporter::Import.new('Client')
    import.clients

    Rake::Task['client_to_shared:copy'].invoke
  end
end
