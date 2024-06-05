module ClearanceCustomFormConcern
  extend ActiveSupport::Concern

  included do
    after_save :flush_overdue_cache, on: :create
    after_save :flush_overdue_cache, on: :update
    after_save :flush_overdue_cache, on: :destroy
  end

  class_methods do
  end

  def flush_overdue_cache
    user = User.current_user

    if user.admin? || user.strategic_overviewer?
      Rails.cache.delete([Apartment::Tenant.current, 'notifications', 'overdue_and_due_today_forms'])
    else
      Rails.cache.delete([Apartment::Tenant.current, 'notifications', 'user', user.id, 'overdue_and_due_today_forms'])
    end
  end
end
