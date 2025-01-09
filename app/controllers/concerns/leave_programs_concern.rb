module LeaveProgramsConcern
  def leave_program_params
    if properties_params.present?
      mappings = {}
      properties_params.each do |k, v|
        mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
      end
      formatted_params = properties_params.map { |k, v| [mappings[k], v] }.to_h
      formatted_params.values.map { |v| v.delete('') if (v.is_a? Array) && v.size > 1 }
    end

    default_params = params.require(:leave_program).permit(:exit_date).merge!(program_stream_id: params[:program_stream_id])
    default_params = default_params.merge!(properties: formatted_params) if formatted_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:leave_program][:form_builder_attachments_attributes]) if action_name == 'create' && attachment_params.present?
    default_params
  end

  def find_entity
    if params[:family_id]
      @entity = Family.includes(enrollments: [:program_stream]).find(params[:family_id])
    elsif params[:community_id]
      @entity = Community.includes(enrollments: [:program_stream]).find(params[:community_id])
    else
      @entity = Client.accessible_by(current_ability).friendly.find(params[:client_id])
    end
  end

  def find_enrollment
    client_enrollment_id = params[:client_enrollment_id] || params[:client_enrolled_program_id]
    enrollment_id = params[:enrollment_id] || params[:enrolled_program_id]
    if client_enrollment_id
      @enrollment = @entity.client_enrollments.find client_enrollment_id
    elsif enrollment_id
      @enrollment = @entity.enrollments.find enrollment_id
    end
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end

  def find_leave_program
    @leave_program = @enrollment.leave_program
  end

  def initial_attachments
    @leave_program = @enrollment.leave_program || @enrollment.build_leave_program
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

  def find_leave_program_path(leave_program)
    if params[:family_id]
      family_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, leave_program)
    elsif params[:community_id]
      community_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, leave_program)
    else
      client_client_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, leave_program)
    end
  end
end
