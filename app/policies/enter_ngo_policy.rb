class EnterNgoPolicy < ApplicationPolicy
  def edit?
    client = Client.find(record.client_id)
    (client.status == 'exited' && user.admin?) || (client.status != 'exited' && !user.strategic_overviewer?)
  end

  alias update? edit?
end
