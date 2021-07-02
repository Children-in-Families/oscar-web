class ClientEnrollmentTrackingPolicy < ApplicationPolicy
  def create?
    record.client_enrollment.active?
  end

  def edit?
    return user.admin? && record.client_enrollment.client.status != 'Exited'
    create?
  end


  alias new? create?
  alias update? create?
end
