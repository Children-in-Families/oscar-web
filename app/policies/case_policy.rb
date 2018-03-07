class CasePolicy < ApplicationPolicy
  def edit?
    record.client.status != 'Exited'
  end

  def update?
    edit?
  end
end
