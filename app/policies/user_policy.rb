class UserPolicy < ApplicationPolicy
  def task_notify?
    record.admin? || record.any_manager?
  end
end