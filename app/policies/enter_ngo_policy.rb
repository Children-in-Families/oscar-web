class EnterNgoPolicy < ApplicationPolicy
  def edit?
    user.admin?
  end

  alias update? edit?
end
