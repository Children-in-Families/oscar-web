class LeaveProgramPolicy < ApplicationPolicy
  def edit?
    if record.enrollment_id
      entity = record.enrollment.programmable
      if record.enrollment.programmable_type == 'Community'
        !user.strategic_overviewer?
      else
        (entity.exit_ngo? && user.admin?) || (!entity.exit_ngo? && !user.strategic_overviewer?)
      end
    elsif record.client_enrollment_id
      client_enrollment = ClientEnrollment.find(record.client_enrollment_id)
      client = Client.find(client_enrollment.client_id)
      (client.exit_ngo? && user.admin?) || (!client.exit_ngo? && !user.strategic_overviewer?)
    end
  end

  def new?
    client_enrollment = ClientEnrollment.find(record.client_enrollment_id)
    client = Client.find(client_enrollment.client_id)

    client.active?
  end

  alias update? edit?
end
