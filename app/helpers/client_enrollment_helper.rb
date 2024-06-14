module ClientEnrollmentHelper
  def view_report_link(program_stream)
    if program_stream.client_enrollments.enrollments_by(@client.id).any?
      link_to t('.view'), report_client_client_enrollments_path(@client, program_stream_id: program_stream)
    end
  end

  def cancel_url
    if action_name == 'new' || action_name == 'create'
      link_to t('.cancel'), client_client_enrollments_path(@client), class: 'btn btn-default form-btn'
    else
      link_to t('.cancel'), client_client_enrollment_path(@client, @client_enrollment, program_stream_id: params[:program_stream_id]), class: 'btn btn-default form-btn'
    end
  end

  def cancel_enrollment_form_path
    if params[:action] == 'new' || params[:action] == 'create'
      link_to t('.cancel'), client_client_enrolled_programs_path(@client, program_streams: 'program-streams'), class: 'btn btn-default form-btn'
    elsif params[:action] == 'edit' || params[:action] == 'update'
      link_to t('.cancel'), client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: params[:program_stream_id]), class: 'btn btn-default form-btn'
    end
  end

  def client_enrollment_form_action_path
    if action_name.in?(%(new create))
      client_client_enrolled_programs_path(@client)
    else
      client_client_enrolled_program_path(@client, @client_enrollment)
    end
  end

  def client_enrollment_edit_link
    if program_permission_editable?(@program_stream)
      link_to edit_client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream) do
        content_tag :div, class: 'btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream) do
        content_tag :div, class: 'btn btn-success btn-outline disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def client_enrollment_new_link(program_stream)
    if program_permission_editable?(program_stream) && policy(@client).create?
      link_to new_client_client_enrollment_path(@client, program_stream_id: program_stream.id) do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width' do
          t('.enroll')
        end
      end
    else
      link_to_if false, new_client_client_enrollment_path(@client, program_stream_id: program_stream.id) do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width disabled' do
          t('.enroll')
        end
      end
    end
  end

  def client_enrollment_destroy_link
    if program_permission_editable?(@program_stream)
      link_to client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream), method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag :div, class: 'btn btn-outline btn-danger' do
          fa_icon('trash')
        end
      end
    else
      link_to_if false, client_client_enrollment_path(@client, @client_enrollment, program_stream_id: @program_stream), method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag :div, class: 'btn btn-outline btn-danger disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def field_label(props, index = nil)
    label = I18n.locale.to_s == I18n.default_locale.to_s ? props['label'] : props['local_label']
  end
end
