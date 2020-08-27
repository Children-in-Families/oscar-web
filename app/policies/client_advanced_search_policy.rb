class ClientAdvancedSearchPolicy < ApplicationPolicy
  def index?
    user.admin? || user.strategic_overviewer? || user.hotline_officer?
  end
end
