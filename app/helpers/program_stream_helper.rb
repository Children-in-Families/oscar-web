module ProgramStreamHelper
  def status_value(program_stream)
    return unless program_stream.has_enrollment?
    program_stream.last_enrollment.status
  end

  def status_label(program_stream)
    return unless program_stream.has_enrollment?
    program_status = program_stream.last_enrollment.status
    program_status == 'Active' ? 'label label-primary' : 'label label-danger'
  end
end
