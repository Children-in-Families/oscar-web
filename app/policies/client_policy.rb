class ClientPolicy < ApplicationPolicy
  def edit?
    record.status != 'Exited'
  end

  def update?
    edit?
  end
end
