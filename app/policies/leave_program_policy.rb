class LeaveProgramPolicy < ApplicationPolicy
  def edit?
    record.client_enrollment.client.status != 'Exited'
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end