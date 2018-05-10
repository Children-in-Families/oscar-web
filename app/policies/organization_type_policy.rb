class OrganizationTypePolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  alias new? index?
  alias create? index?
  alias edit? index?
  alias update? index?
  alias destroy? index?
  alias version? index?
end
