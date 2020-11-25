class EnrollmentPolicy < ApplicationPolicy
  def create?
    if (enrollments_by_entity.empty? || enrollments_by_entity.last.status == 'Exited')
      return true unless record.program_stream.try(:quantity).present?
      entity_ids.size < record.program_stream.quantity
    else
      return false
    end
  end

  def edit?
    entity = record.programmable
    (entity.exit_ngo? && user.admin?) || (!entity.exit_ngo? && !user.strategic_overviewer?)
  end

  alias new? create?
  alias update? edit?

  def entity_ids
    Enrollment.active.where(program_stream_id: record.program_stream).pluck(:programmable_id).uniq
  end

  private

  def enrollments_by_entity
    programmable_id = record.programmable_id
    program_stream_id = record.program_stream_id
    Enrollment.where(programmable_id: programmable_id, program_stream_id: program_stream_id).order(:created_at)
  end
end
