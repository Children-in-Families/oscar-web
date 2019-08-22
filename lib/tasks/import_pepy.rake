namespace :pepy do
  desc 'Import Pepy Empowering Youth Organization'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'pepy', full_name: "Pepy Empowering Youth", logo: File.open(Rails.root.join('app/assets/images/pepy_logo.jpg')))
    Organization.switch_to'pepy'
    Rake::Task['basic_data:import'].invoke
    User.create_with(first_name: 'Sarakk', last_name: '', roles: 'admin', gender: 'other', enable_gov_log_in: true, enable_research_log_in: true, referral_notification: true, password: ENV['PEPY_PASSWORD']).find_or_create_by(email: ENV['PEPY_EMAIL'])
  end
end
