class ClientPolicy < ApplicationPolicy
  def edit?
    record.status != 'Exited'
  end

  alias new? edit?
  alias create? edit?
  alias update? edit?
  alias destroy? edit?
end
