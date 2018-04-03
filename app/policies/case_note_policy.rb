class CaseNotePolicy < ApplicationPolicy
  def edit?
    return true if user.admin?
    record.created_at.today?
  end

  alias update? edit?

  class Scope < Scope
    def resolve
      scope
    end
  end
end
