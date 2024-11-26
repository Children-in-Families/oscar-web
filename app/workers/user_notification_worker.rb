class UserNotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, short_name)
    # Do something
    Apartment::Tenant.switch short_name
    user = User.find(user_id)

    if user.admin? || user.strategic_overviewer?
      Rails.cache.delete([Apartment::Tenant.current, 'notifications', 'admin-strategic-overviewer'])
    else
      Rails.cache.delete([Apartment::Tenant.current, 'notifications', 'user', user.id])
    end

    user.fetch_notification
  end
end
