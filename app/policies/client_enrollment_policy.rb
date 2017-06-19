class ClientEnrollmentPolicy < ApplicationPolicy  
  def update?
    record.status == 'Active'
  end

  def create?
    return true unless record.program_stream.quantity.present?
    client_ids.size < record.program_stream.quantity
  end

  def client_ids
    ClientEnrollment.active.where(program_stream_id: record.program_stream).pluck(:client_id).uniq
  end
end