namespace :brc do
  desc 'Create new organization and import all related data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'brc', full_name: 'Bahamas Red Cross', logo: File.open(Rails.root.join('app/assets/images/brc.png')))
    Organization.switch_to 'brc'
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
  end
end
