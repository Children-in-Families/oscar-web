class ClientEnrollmentPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    if (enrollments_by_client.empty? || enrollments_by_client.last.status == 'Exited') && status_not_exited?
      return true unless record.program_stream.quantity.present?
      client_ids.size < record.program_stream.quantity
    else
      return false
    end
  end

  def edit?
    status_not_exited?
  end

  def update?
    status_not_exited?
  end

  def client_ids
    ClientEnrollment.active.where(program_stream_id: record.program_stream).pluck(:client_id).uniq
  end

  private

  def status_not_exited?
    record.client.status != 'Exited'
  end

  def enrollments_by_client
    client_id = record.client_id
    program_stream_id = record.program_stream_id
    ClientEnrollment.where(client_id: client_id, program_stream_id: program_stream_id).order(:created_at)
  end
end