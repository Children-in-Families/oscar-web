class ClientEnrollmentTrackingPolicy < ApplicationPolicy
  def create?
    record.client_enrollment.status == 'Active'
  end

  def update?
    create?
  end
  
end