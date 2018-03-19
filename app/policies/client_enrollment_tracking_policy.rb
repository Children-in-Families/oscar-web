class ClientEnrollmentTrackingPolicy < ApplicationPolicy
  def create?
    record.client_enrollment.active?
  end

  alias new? create?
  alias edit? create?
  alias update? create?
end
