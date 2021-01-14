module LeaveEnrolledProgramHelper
  def leave_enrolled_program_edit_link
    path = params[:family_id] ? edit_family_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program, program_stream_id: @program_stream) : edit_client_client_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program, program_stream_id: @program_stream)
    if program_permission_editable?(@program_stream)
      link_to path do
        content_tag :div, class: 'btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: 'btn btn-success btn-outline disabled' do
          fa_icon('pencil')
        end
      end
    end
  end
end
