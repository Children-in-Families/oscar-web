module LeaveProgramsConcern
  def leave_program_params
    properties_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 } if properties_params.present?

    default_params = params.require(:leave_program).permit(:exit_date).merge!(program_stream_id: params[:program_stream_id])
    default_params = default_params.merge!(properties: properties_params) if properties_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:leave_program][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
    default_params
  end

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find params[:client_id]
  end

  def find_enrollment
    enrollment_id = params[:client_enrollment_id] || params[:client_enrolled_program_id]
    @enrollment = @client.client_enrollments.find enrollment_id
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end

  def find_leave_program
    @leave_program = @enrollment.leave_program
  end

  def initial_attachments
    @leave_program = @enrollment.build_leave_program
    @attachments = @leave_program.form_builder_attachments
  end

  def get_attachments
    @attachments = @leave_program.form_builder_attachments
  end

  def check_user_permission(permission)
    unless current_user.admin? || current_user.strategic_overviewer?
      permission_set = current_user.program_stream_permissions.find_by(program_stream_id: @program_stream.id)[permission]
      redirect_to root_path, alert: t('unauthorized.default') unless permission_set
    end
  end
end
