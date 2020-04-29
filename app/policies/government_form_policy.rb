class GovernmentFormPolicy < ApplicationPolicy
  def create?
    ClientPolicy.new(user_context, record.client).create?
  end

  alias show? create?
  alias new? create?
  alias edit? create?
  alias update? create?
  alias destroy? create?
  alias duplicate? create?
end
