class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(short_name)
    Apartment::Tenant.switch short_name
    users_ids = User.non_locked.without_deleted_users.ids
    users_ids.each_with_index do |user_id, index|
      UserNotificationWorker.perform_in(3 + index, user_id, short_name)
    end
  end
end
