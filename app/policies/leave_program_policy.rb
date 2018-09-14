class LeaveProgramPolicy < ApplicationPolicy
  def edit?
    client_enrollment = ClientEnrollment.find(record.client_enrollment_id)
    client = Client.find(client_enrollment.client_id)
    (client.exit_ngo? && user.admin?) || (!client.exit_ngo? && !user.strategic_overviewer?)
  end

  alias update? edit?
end
