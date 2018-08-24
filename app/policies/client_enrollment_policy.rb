class ClientEnrollmentPolicy < ApplicationPolicy
  def create?
    if (enrollments_by_client.empty? || enrollments_by_client.last.status == 'Exited')
      return true unless record.program_stream.try(:quantity).present?
      client_ids.size < record.program_stream.quantity
    else
      return false
    end
  end

  def edit?
    client = Client.find(record.client_id)
    (client.exit_ngo? && user.admin?) || (!client.exit_ngo? && !user.strategic_overviewer?)
  end

  alias new? create?
  alias update? edit?

  def client_ids
    ClientEnrollment.active.where(program_stream_id: record.program_stream).pluck(:client_id).uniq
  end

  private

  def enrollments_by_client
    client_id = record.client_id
    program_stream_id = record.program_stream_id
    ClientEnrollment.where(client_id: client_id, program_stream_id: program_stream_id).order(:created_at)
  end
end
