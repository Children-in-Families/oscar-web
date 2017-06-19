class ClientEnrollmentPolicy < ApplicationPolicy  
  def update?
    record.status == 'Active'
  end

  def create?
    if get_client_enrollments.empty? || client_enrollment_status == 'Exited'
      return true unless record.program_stream.quantity.present?
      client_ids.size < record.program_stream.quantity
    else
      return false
    end
  end

  def client_ids
    ClientEnrollment.active.where(program_stream_id: record.program_stream).pluck(:client_id).uniq
  end

  private

  def client_enrollment_status
    client_id = record.client_id
    program_stream_id = record.program_stream_id

    ClientEnrollment.where(client_id: client_id, program_stream_id: program_stream_id).order(:created_at).last.status
  end

  def get_client_enrollments
    record.program_stream.client_enrollments
  end
end