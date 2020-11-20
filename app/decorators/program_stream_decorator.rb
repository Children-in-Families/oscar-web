class ProgramStreamDecorator < Draper::Decorator
  delegate_all

  def enrollment_status_value(obj, entity_type = nil)
    if ['Family'].include?(entity_type)
      enrollments = model.enrollments.with_deleted.enrollments_by(obj.id).order(:created_at)
      return unless enrollments.present?
      enrollments.last.status
    else
      enrollments = model.client_enrollments.with_deleted.enrollments_by(obj).order(:created_at)
      return unless enrollments.present?
      enrollments.last.status
    end
  end

  def enrollment_status_label(obj, entity_type = nil)
    program_status = enrollment_status_value(obj, entity_type: entity_type)
    return if program_status.nil?
    program_status == 'Active' ? 'label label-primary' : 'label label-danger'
  end

  def completed_label_class
    model.completed? ? 'label label-primary' : 'label label-danger'
  end

  def completed_status
    model.completed? ? 'Completed' : 'Incompleted'
  end

  def maximum_client?
    model.quantity.present? && model.client_enrollments.active.size >= model.quantity
  end

  def maximum_entity?
    model.quantity.present? && model.enrollments.active.size >= model.quantity
  end

  def place_available
    model.quantity.present? ? model.number_available_for_client : ''
  end

  def enrolled
    model.completed == true ? model.client_enrollments.active.size : ''
  end

  def domains_format
    model.domains.pluck(:identity)
  end
end
