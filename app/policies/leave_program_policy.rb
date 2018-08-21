class LeaveProgramPolicy < ApplicationPolicy
  def edit?
    client_enrollment = ClientEnrollment.find(record.client_enrollment_id)
    client = Client.find(client_enrollment.client_id)
    (client.status == 'exited' && user.admin?) || (client.status != 'exited' && !user.strategic_overviewer?)
  end

  alias update? edit?
end
