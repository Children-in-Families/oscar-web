module ClientEnrollmentHelper
  def view_report_link(program_stream)
    if program_stream.client_enrollments.enrollments_by(@client.id).order(:created_at).last.try(:status) == 'Exited'
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

  def program_stream_readable?(value)
    return true if current_user.admin? || current_user.strategic_overviewer?
    current_user.program_stream_permissions.find_by(program_stream_id: value).readable
  end

  def client_enrollment_edit_link(client, client_enrollment, program_stream)
    if program_permission_editable?(program_stream)
      link_to edit_client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream) do
        content_tag :div, class: 'btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_client_client_enrollment_path(client, client_enrollment, program_stream_id: program_stream) do
        content_tag :div, class: 'btn btn-success btn-outline disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def program_permission_editable?(value)
    return true if current_user.admin?
    return false if current_user.strategic_overviewer?
    current_user.program_stream_permissions.find_by(program_stream_id: value.id).editable
  end
end
