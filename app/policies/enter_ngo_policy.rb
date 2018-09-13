class EnterNgoPolicy < ApplicationPolicy
  def edit?
    client = Client.find(record.client_id)
    (client.exit_ngo? && user.admin?) || (!client.exit_ngo? && !user.strategic_overviewer?)
  end

  alias update? edit?
end
