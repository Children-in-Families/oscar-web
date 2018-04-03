class ClientPolicy < ApplicationPolicy
  def create?
    record.status != 'Exited'
  end
end
