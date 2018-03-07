class CaseNotePolicy < ApplicationPolicy
  def new?
    record.client.status != 'Exited'
  end

  def create?
    new?
  end

  def edit?
    record.created_at.today? && record.client.status != 'Exited'
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
