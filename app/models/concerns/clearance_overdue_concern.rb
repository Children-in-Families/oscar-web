module ClearanceOverdueConcern
  extend ActiveSupport::Concern

  included do
    after_commit :flush_overdue_cache
  end

  class_methods do
  end

  def flush_overdue_cache
    user = User.current_user
    if user.admin? || user.strategic_overviewer?
      Rails.cache.delete([Apartment::Tenant.current, 'notifications', 'admin-strategic-overviewer'])
    else
      Rails.cache.delete([Apartment::Tenant.current, 'notifications', 'user', user.id])
    end
  end
end
