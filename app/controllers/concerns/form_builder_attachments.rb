module FormBuilderAttachments
  def add_more_attachments(resource)
    return unless attachment_params.present?
    attachment_params.each do |_k, attachment|
      name = attachment['name']
      if name.present? && attachment['file'].present?
        form_builder_attachment = resource.form_builder_attachments.file_by_name(name)
        modify_files = form_builder_attachment.file
        modify_files += attachment['file']

        form_builder_attachment = resource.form_builder_attachments.file_by_name(name)
        form_builder_attachment.file = modify_files
        form_builder_attachment.save
      end
    end
  end

  def attachment_params
    if controller_name == 'client_enrollments'
      params[:client_enrollment][:form_builder_attachments_attributes]
    elsif controller_name == 'client_enrollment_trackings'
      params[:client_enrollment_tracking][:form_builder_attachments_attributes]
    elsif controller_name == 'leave_programs'
      params[:leave_program][:form_builder_attachments_attributes]
    end
  end
end
