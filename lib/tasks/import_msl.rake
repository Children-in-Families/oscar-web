namespace :msl do
  desc 'Import Mith Samlanh org'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'msl', full_name: "Mith Samlanh", logo: File.open(Rails.root.join('app/assets/images/msl.jpg')))
    Organization.switch_to 'msl'
    Rake::Task['basic_data:import'].invoke

    import     = MslImporter::Import.new('Users')
    import.users

    import     = MslImporter::Import.new('Client')
    import.clients
  end
end
