class TaskPolicy < ApplicationPolicy
  def edit?
    record.client.status != 'Exited'
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
