module EnrolledProgramHelper
  def program_stream_tracking_action_link(program_stream)
    if params[:family_id]
      path = family_enrolled_program_enrolled_program_trackings_path(@programmable, program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last)
    elsif params[:community_id]
      path = community_enrolled_program_enrolled_program_trackings_path(@programmable, program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last)
    else
      path = '#'
    end

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
    if params[:family_id]
      path = edit_family_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream)
    elsif params[:community_id]
      path = edit_community_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream)
    else
      path = '#'
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

  def enrolled_program_destroy_link
    if params[:family_id]
      path = family_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream)
    elsif params[:community_id]
      path = community_enrolled_program_path(@programmable, @enrollment, program_stream_id: @program_stream)
    else
      path = '#'
    end

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
    if params[:family_id]
      path = new_family_enrolled_program_leave_enrolled_program_path(@programmable, program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last)
    elsif params[:community_id]
      path = new_community_enrolled_program_leave_enrolled_program_path(@programmable, program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last)
    else
      path = '#'
    end

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
    if params[:family_id]
      family_enrolled_program_leave_enrolled_program_path(@programmable, enrollment, enrollment.leave_program)
    elsif params[:community_id]
      community_enrolled_program_leave_enrolled_program_path(@programmable, enrollment, enrollment.leave_program)
    else
      '#'
    end
  end
end
