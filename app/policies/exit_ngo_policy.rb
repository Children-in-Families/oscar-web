class ExitNgoPolicy < ApplicationPolicy
  def edit?
    entity = find_entity
    (entity.exit_ngo? && user.admin?) || (!entity.exit_ngo? && !user.strategic_overviewer?)
  end

  def destroy?
    entity = find_entity
    (entity.exit_ngo? && user.admin?) && entity.exit_ngos.last == record
  end

  def find_entity
    if record.attached_to_family?
      Family.find(record.rejectable_id)
    else
      Client.find(record.client_id)
    end
  end

  alias update? edit?
end
