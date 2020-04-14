namespace :flame do
  desc 'Import all Flame clients and related data'
  task import: :environment do
    org = Organization.create_and_build_tenant(short_name: 'fco', full_name: "Flame Cambodia", logo: File.open(Rails.root.join('app/assets/images/flame.jpg')))
    Organization.switch_to 'fco'

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
    Rake::Task['districts:import'].invoke

    import     = FlameImporter::Import.new('Users')
    import.users

    import     = FlameImporter::Import.new('Family')
    import.families

    import     = FlameImporter::Import.new('Client')
    import.clients
  end
end
