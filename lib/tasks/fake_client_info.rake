namespace :fake_client_info do
  desc 'Invoke fake client data'
  task update: :environment do |task, args|
    Rake::Task["change_client_profile:update"].invoke
    Rake::Task["change_assessment_data:update"].invoke
    Rake::Task["change_casenote_data:update"].invoke
  end
end
