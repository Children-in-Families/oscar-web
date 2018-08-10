class LeaveProgramPolicy < ApplicationPolicy
  def edit?
    user.admin?
  end

  alias update? edit?
end
