class ExitNgoPolicy < ApplicationPolicy
  def edit?
    if record.attached_to_family?
      entity = Family.find(record.rejectable_id)
    else
      entity = Client.find(record.client_id)
    end
    (entity.exit_ngo? && user.admin?) || (!entity.exit_ngo? && !user.strategic_overviewer?)
  end

  alias update? edit?
end
