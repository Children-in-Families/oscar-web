module EnrollmentTrackingsConcern
  def enrollment_tracking_params
    if entity_properties_params.present?
      mappings = {}
      entity_properties_params.each do |k, v|
        mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
      end
      formatted_params = entity_properties_params.map {|k, v| [mappings[k], v] }.to_h
      formatted_params.values.map{ |v| v.delete('') if (v.is_a?Array) && v.size > 1 }
    end
    default_params = params.require(:enrollment_tracking).permit({}).merge!(tracking_id: params[:tracking_id])
    default_params = default_params.merge!(properties: formatted_params) if formatted_params.present?
    default_params = default_params.merge!(form_builder_attachments_attributes: params[:enrollment_tracking][:form_builder_attachments_attributes]) if action_name == 'create' && entity_attachment_params.present?
    default_params
  end

  private

  def find_entity
    if params[:family_id].present?
      @programmable = Family.includes(enrollments: [:program_stream]).find(params[:family_id])
    end
  end

  def find_enrollment
    emrollment_id = params[:enrollment_id] || params[:enrolled_program_id]
    @enrollment = @programmable.enrollments.find emrollment_id
  end

  def find_program_stream
    @program_stream = @enrollment.program_stream
  end

  def find_tracking
    @tracking = @program_stream.trackings.find(params[:tracking_id])
  end

  def find_enrollment_tracking
    @enrollment_tracking = @enrollment.enrollment_trackings.find(params[:id])
  end

  def get_attachments
    @enrollment_tracking ||= @enrollment.enrollment_trackings.new
    @attachments = @enrollment_tracking.form_builder_attachments
  end

  def check_user_permission(permission)
    unless current_user.admin? || current_user.strategic_overviewer?
      permission_set = current_user.program_stream_permissions.find_by(program_stream_id: @program_stream.id)[permission]
      redirect_to root_path, alert: t('unauthorized.default') unless permission_set
    end
  end
end
