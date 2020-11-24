module EnrollmentTrackingHelper
  def enrolled_tracking_new_link(tracking_id)
    path = params[:family_id] ? new_family_enrolled_program_enrolled_program_tracking_path(@programmable, @enrollment, tracking_id: tracking_id) : '#'
    if program_permission_editable?(@enrollment.program_stream_id)
      link_to path do
        content_tag :div, class: 'btn btn-primary btn-outline' do
          t('.new_tracking')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: 'btn btn-primary btn-outline disabled' do
          t('.new_tracking')
        end
      end
    end
  end

  def enrolled_tracking_edit_link(enrollment_tracking)
    path = params[:family_id] ? edit_family_enrolled_program_enrolled_program_tracking_path(@programmable, @enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking) : '#'
    if program_permission_editable?(@enrollment.program_stream_id)
      link_to path do
        content_tag :div, class: ' btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: ' btn btn-success btn-outline disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def enrollment_tracking_destroy_link(enrollment_tracking)
    path = params[:family_id] ? family_enrolled_program_enrolled_program_tracking_path(@programmable, @enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking) : '#'
    if program_permission_editable?(@enrollment.program_stream_id)
      link_to path, method: 'delete',  data: { confirm: t('.are_you_sure') } do
        content_tag :div, class: 'btn btn-danger btn-outline' do
          fa_icon('trash')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: 'btn btn-danger btn-outline disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def enrollment_tracking_form_action
    if action_name.in?(%(new create))
      params[:family_id] ? family_enrolled_program_enrolled_program_trackings_path(@programmable, @enrollment) : '#'
    else
      params[:family_id] ? family_enrolled_program_enrolled_program_tracking_path(@programmable, @enrollment, @enrollment_tracking) : '#'
    end
  end
end

