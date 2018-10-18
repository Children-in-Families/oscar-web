namespace :hope_for_justice do
  desc 'Launch Hope for Justice instance'
  task import: :environment do
    Organization.create_and_build_tanent(short_name: 'hfj', full_name: 'Hope for Justice', country: 'cambodia', logo: File.open(Rails.root.join('app/assets/images/Hope-for-Justice.jpg')))
    Organization.switch_to 'hfj'
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
