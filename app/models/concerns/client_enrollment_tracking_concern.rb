module ClientEnrollmentTrackingConcern
  extend ActiveSupport::Concern
  included do
    validate do |obj|
      case obj.class.name
      when 'ClientEnrollment'
        object_parameter(obj, 'program_stream', 'enrollment')
      when 'LeaveProgram'
        object_parameter(obj, 'program_stream', 'exit_program')
      when 'CustomFieldProperty'
        object_parameter(obj, 'custom_field', 'fields')
      when 'ClientEnrollmentTracking'
        object_parameter(obj, 'tracking', 'fields')
      end
    end
  end

  class_methods do
  end

  def instance_method
  end

  def object_parameter(obj, klass_name, field_name)
    CustomFormPresentValidator.new(obj, klass_name, field_name).validate
    CustomFormNumericalityValidator.new(obj, klass_name, field_name).validate
    CustomFormEmailValidator.new(obj, klass_name, field_name).validate
  end
end
