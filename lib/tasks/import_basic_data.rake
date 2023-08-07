
namespace :basic_data do
  desc 'Import all basic data task'
  task import: :environment do
    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['districts:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['communes_and_villages:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
  end
end
