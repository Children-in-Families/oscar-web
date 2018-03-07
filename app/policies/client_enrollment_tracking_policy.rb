class ClientEnrollmentTrackingPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    record.client_enrollment.active? && record.client_enrollment.client.status != 'Exited'
  end

  def edit?
    create?
  end

  def update?
    create?
  end
end
