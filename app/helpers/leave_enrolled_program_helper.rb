module LeaveEnrolledProgramHelper
  def leave_enrolled_program_edit_link
    if params[:family_id]
      path = edit_family_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program, program_stream_id: @program_stream)
    elsif params[:community_id]
      path = edit_community_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program, program_stream_id: @program_stream)
    else
      path = edit_client_client_enrolled_program_leave_enrolled_program_path(@entity, @enrollment, @leave_program, program_stream_id: @program_stream)
    end

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

  def entity_report_path
    if params[:family_id]
      report_family_enrolled_programs_path(@entity, program_stream_id: @program_stream)
    elsif params[:community_id]
      report_community_enrolled_programs_path(@entity, program_stream_id: @program_stream)
    else
      report_client_client_enrolled_programs_path(@entity, program_stream_id: @program_stream)
    end
  end
end
