class ClientEnrollmentTrackingPolicy < ApplicationPolicy
  def create?
    record.client_enrollment.active?
  end

  def update?
    create?
  end
end
