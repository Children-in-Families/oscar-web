class UserPolicy < ApplicationPolicy
  def task_notify?
    record.admin? || record.any_manager? || record.hotline_officer?
  end

  def staff_performance_notification?
    record.admin? || record.any_manager? || record.hotline_officer?
  end
end
