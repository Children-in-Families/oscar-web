class EnrollmentTrackingPolicy < ApplicationPolicy
  def create?
    record.enrollment.active?
  end

  alias new? create?
  alias edit? create?
  alias update? create?
end
