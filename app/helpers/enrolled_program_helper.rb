module EnrolledProgramHelper
  def program_stream_tracking_action_link(program_stream)
    path = params[:family_id] ? family_enrolled_program_enrolled_program_trackings_path(@programmable, program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last) : '#'
    if program_permission_editable?(program_stream)
      link_to path do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width' do
          t('.tracking')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width disabled' do
          t('.tracking')
        end
      end
    end
  end

  def enrolled_program_edit_link
    path = params[:family_id] ? edit_family_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream) : '#'
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

  def enrolled_program_destroy_link
    path = params[:family_id] ? family_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream) : '#'
    if program_permission_editable?(@program_stream)
      link_to path, method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag :div, class: 'btn btn-outline btn-danger' do
          fa_icon('trash')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: 'btn btn-outline btn-danger disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def program_stream_exit_action_link(program_stream)
    path = params[:family_id] ? new_family_enrolled_program_leave_enrolled_program_path(@programmable, program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last) : '#'
    if program_permission_editable?(program_stream)
      link_to path do
        content_tag :div, class: 'btn btn-danger btn-xs btn-width' do
          t('.exit')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: 'btn btn-danger btn-xs btn-width disabled' do
          t('.exit')
        end
      end
    end
  end

  def enrolled_program_leave_enrolled_program_link(enrollment)
    params[:family_id] ? family_enrolled_program_leave_enrolled_program_path(@programmable, enrollment, enrollment.leave_program) : '#'
  end
end
