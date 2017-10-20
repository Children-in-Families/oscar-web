module ClientEnrolledProgramHelper
  def client_enrolled_program_edit_link(client, client_enrollment, program_stream)
    if program_permission_editable?(program_stream)
      link_to edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream) do
        content_tag :div, class: 'btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_client_client_enrolled_program_path(client, client_enrollment, program_stream_id: program_stream) do
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