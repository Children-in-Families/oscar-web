namespace :pepy do
  desc 'Import Pepy Empowering Youth Organization'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'pepy', full_name: "Pepy Empowering Youth", logo: File.open(Rails.root.join('app/assets/images/pepy_logo.jpg')))
    Organization.switch_to org.short_name
    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['districts:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke
    Rake::Task['communes_and_villages:import'].invoke
    Rake::Task['communes_and_villages:import'].reenable
    User.create_with(first_name: 'Sarakk', last_name: '', roles: 'admin', gender: 'other', enable_gov_log_in: true, enable_research_log_in: true, referral_notification: true, password: ENV['PEPY_PASSWORD']).find_or_create_by(email: ENV['PEPY_EMAIL'])
  end
end
