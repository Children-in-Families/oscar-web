namespace :tutorials do
  desc 'Create tutorials instance'
  task create: :environment do
    org = Organization.create_and_build_tenant(short_name: 'tutorials', full_name: 'Tutorials', country: 'cambodia', logo: File.open(Rails.root.join('app/assets/images/OSCaR.png')))
    Organization.switch_to org.short_name
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
