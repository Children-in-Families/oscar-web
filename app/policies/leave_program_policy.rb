class LeaveProgramPolicy < ApplicationPolicy
  def edit?
    if record.enrollment_id
      entity = record.enrollment.programmable
      (entity.exit_ngo? && user.admin?) || (!entity.exit_ngo? && !user.strategic_overviewer?)
    elsif record.client_enrollment_id
      client_enrollment = ClientEnrollment.find(record.client_enrollment_id)
      client = Client.find(client_enrollment.client_id)
      (client.exit_ngo? && user.admin?) || (!client.exit_ngo? && !user.strategic_overviewer?)
    end
  end

  alias update? edit?
end
