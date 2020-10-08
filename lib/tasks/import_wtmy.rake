namespace :wtmy do
  desc 'Import Holt data'
  task import: :environment do
    # org = Organization.create_and_build_tenant(short_name: 'holt', full_name: "Holt International Cambodia", logo: File.open(Rails.root.join('app/assets/images/holt.jpg')), fcf_ngo: true)
    Organization.switch_to 'wtmy'

    Rake::Task['db:seed'].invoke
    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['nepali_provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
    Setting.first.update(country_name: 'nepal')
    Rake::Task["field_settings:import"].invoke('wtmy')
    # import = HoltImporter::Import.new('Family')
    # import.families
    # path = Rails.root.join("vendor/data/organizations/client_data_import_nepal.xlsx")
    # import = HoltImporter::Import.new('users', path)
    # import.users

    # import = HoltImporter::Import.new('clients', path)
    # import.clients
  end
end
