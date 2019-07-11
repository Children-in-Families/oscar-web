namespace :gct do
  desc 'Import Mith Samlanh org'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'msl', full_name: "Mith Samlanh", logo: File.open(Rails.root.join('app/assets/images/msl.jpg')))
    Organization.switch_to org.short_name
    Rake::Task['basic_data:import'].invoke
  end
end