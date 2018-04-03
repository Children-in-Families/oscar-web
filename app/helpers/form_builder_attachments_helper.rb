module FormBuilderAttachmentsHelper
  def form_buildable_path(resource, index, label, params_program_stream)
    if controller_name == 'leave_programs' || controller_name == 'leave_enrolled_programs'
      link_to polymorphic_path([@client, resource.client_enrollment, resource], program_stream_id: @program_stream.id, file_index: index, file_name: label, program_streams: params_program_stream), method: :delete, data: { confirm: t('.are_you_sure') }, class: "delete btn btn-outline btn-danger #{disabled?}" do
        fa_icon('trash')
      end
    elsif controller_name == 'client_enrollment_trackings' || controller_name == 'client_enrolled_program_trackings'
      link_to polymorphic_path([@client, resource.client_enrollment, resource], program_stream_id: @program_stream.id, file_index: index, file_name: label, program_streams: params_program_stream), method: :delete, data: { confirm: t('.are_you_sure') }, class: "delete btn btn-outline btn-danger #{disabled?}" do
        fa_icon('trash')
      end
    elsif controller_name == 'client_enrollments' || controller_name == 'client_enrolled_programs'
      link_to polymorphic_path([@client, resource], program_stream_id: @program_stream.id, file_index: index, file_name: label), method: :delete, data: { confirm: t('.are_you_sure') }, class: "delete btn btn-outline btn-danger #{disabled?}" do
        fa_icon('trash')
      end
    elsif controller_name == 'custom_field_properties'
      link_to polymorphic_path([@custom_formable, resource], custom_field_id: @custom_field.id, file_index: index, file_name: label), method: :delete, data: { confirm: t('.are_you_sure') }, class: "delete btn btn-outline btn-danger #{disabled?}" do
        fa_icon('trash')
      end
    end
  end

  def disabled?
    return if current_user.admin? && authorize_client?
    return 'disabled' if current_user.strategic_overviewer?
    permission = current_user.custom_field_permissions.find_by(custom_field_id: params[:custom_field_id]).try(:editable)
    'disabled' unless permission
  end

  def authorize_client?
    if @custom_formable.present?
       @custom_formable.class.name == 'Client' ? policy(@custom_formable).create? : true
    else
      policy(@client).create?
    end
  end

  def custom_field_property_attachment(field)
    if action_name == 'create'
      @attachments = @custom_field_property.form_builder_attachments.build
    else
      @attachments.file_by_name(field) || @attachments.build
    end
  end
end
