namespace :connect_street_services do
  desc 'Launch Connect Street Services instance'
  task import: :environment do
    Organization.create_and_build_tanent(short_name: 'css', full_name: 'Connect Street Services', country: 'cambodia', logo: File.open(Rails.root.join('app/assets/images/CONNECT-Street-Work.jpg')))
    Organization.switch_to 'css'
    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['districts:import'].invoke
    Rake::Task['communes_and_villages:import'].invoke
    Rake::Task['db:seed'].invoke
  end
end
