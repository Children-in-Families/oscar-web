namespace :cvcd do
  desc 'Import all cvcd clients and related data'
  task import: :environment do
    org = Organization.create_and_build_tenant(short_name: 'cvcd', full_name: 'Cambodian Volunteers For Community Development Organization', logo: File.open(Rails.root.join('app/assets/images/CVCD logo.jpeg')))
    Organization.switch_to 'cvcd'

    Rake::Task['basic_data:import'].invoke

    import     = CvcdImporter::Import.new('Users')
    import.users

    import     = CvcdImporter::Import.new('Client')
    import.clients
  end
end
