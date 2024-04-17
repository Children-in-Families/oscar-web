namespace :notifications do
  desc 'Cache all notifications'
  task :cache, [:short_name] => :environment do |task, args|
    include ProgramStreamHelper
    include CsiConcern

    if args.short_name
      Organization.switch_to args.short_name
      users = User.without_deleted_users
      map_users_notifications(users, args.short_name)
    else
      Organization.all.each do |org|
        Organization.switch_to org.short_name
        users = User.without_deleted_users
        map_users_notifications(users, org.short_name)
      end
    end
  end
end

def map_users_notifications(users, short_name)
  users.each do |user|
    user.fetch_notification
  end
end
