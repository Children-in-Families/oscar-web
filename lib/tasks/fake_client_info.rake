namespace :fake_client_info do
  desc 'Invoke fake client data'
  task :update, [:short_name] => :environment do |task, args|
    Rake::Task["change_client_profile:update"].invoke(args.short_name)
    Rake::Task["change_assessment_data:update"].invoke(args.short_name)
    Rake::Task["change_casenote_data:update"].invoke(args.short_name)
  end
end
