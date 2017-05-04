class ClientAdvancedSearchPolicy < ApplicationPolicy
  def index?
    user.admin? || user.strategic_overviewer?
  end
end
