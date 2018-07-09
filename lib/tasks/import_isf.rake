namespace :import_isf do
  desc 'Import Indochina Starfish Foundation clients and related data'
  task start: :environment do
    org = Organization.create_and_build_tanent(short_name: 'isf', full_name: 'Indochina Starfish Foundation', logo: File.open(Rails.root.join('app/assets/images/isf.png')))
    Organization.switch_to org.short_name

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['districts:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import = IsfImporter::Import.new('users')
    import.users

    import = IsfImporter::Import.new('clients')
    import.clients
  end
end
