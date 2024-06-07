namespace :notifications do
  desc 'Cache all notifications'
  task :cache, [:short_name] => :environment do |task, args|
    include ProgramStreamHelper
    include CsiConcern

    if args.short_name
      Organization.switch_to args.short_name
      users_ids = User.non_locked.without_deleted_users.ids
      users_ids.each_with_index do |user_id, index|
        UserNotificationWorker.perform_in(5 + index, user_id, args.short_name)
      end
    else
      Organization.all.each_with_index do |org, index|
        NotificationWorker.perform_in((5 + index).minutes, org.short_name)
      end
    end
  end
end
