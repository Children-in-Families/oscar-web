class ClientEnrollmentTrackingPolicy < ApplicationPolicy
  def create?
    true
  end

  def edit?
    # return user.admin? && record.client_enrollment.client.status != 'Exited'
    create?
  end

  def new?
    return false if record.tracking&.hidden

    create?
  end

  alias update? create?
end
