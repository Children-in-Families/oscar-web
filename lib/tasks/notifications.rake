namespace :notifications do
  desc 'Cache all notifications'
  task :cache, [:short_name] => :environment do |task, args|
    include ProgramStreamHelper
    include CsiConcern
    include NotificationMappingConcern

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
    user_ability = Ability.new(user)
    clients = Client.accessible_by(user_ability).non_exited_ngo
    notifications = UserNotification.new(user, clients)
    notifications = JSON.parse(notifications.to_json)
    Rails.cache.delete([short_name, 'notifications', 'user', user.id])
    Rails.cache.fetch([short_name, 'notifications', 'user', user.id]) do
      map_notification_payloads(notifications)
    end
  end
end
