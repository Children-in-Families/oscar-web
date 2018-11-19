namespace :women do
  desc 'Import all women data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'wmo', full_name: "Women Cambodia", logo: File.open(Rails.root.join('app/assets/images/women_ngo.png')))
    Organization.switch_to 'wmo'
    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['districts:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
    Rake::Task['communes_and_villages:import'].invoke
    Rake::Task['communes_and_villages:import'].reenable
    
  end
end
