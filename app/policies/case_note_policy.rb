class CaseNotePolicy < ApplicationPolicy
  def edit?
    record.created_at.today?
  end

  def update?
    edit?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
