module ClientEnrollmentTrackingHelper
  def tracking_report(tracking)
    @program_stream.trackings.find(tracking.tracking_id).fields
  end

  def client_enrollment_tracking_form_action_path
    if action_name.in?(%(new create))
      client_client_enrolled_program_client_enrolled_program_trackings_path(@client, @enrollment)
    else
      client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, @client_enrollment_tracking)
    end
  end

  def client_enrollment_tracking_edit_link(enrollment_tracking)
    if program_permission_editable?(@enrollment.program_stream_id) && policy(enrollment_tracking).edit?
      link_to edit_client_client_enrollment_client_enrollment_tracking_path(@client, @enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking) do
        content_tag :div, class: 'btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_client_client_enrollment_client_enrollment_tracking_path(@client, @enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking) do
        content_tag :div, class: 'btn btn-success btn-outline disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def client_enrolled_tracking_edit_link(enrollment_tracking)
    if program_permission_editable?(@enrollment.program_stream_id) && enrollment_tracking.is_tracking_editable_limited? && enrollment_tracking.allowed_edit?(current_user)
      link_to edit_client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking) do
        content_tag :div, class: ' btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking) do
        content_tag :div, class: ' btn btn-success btn-outline disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def client_enrollment_tracking_destroy_link(enrollment_tracking)
    if program_permission_editable?(@enrollment.program_stream_id)
      link_to client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking), method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag :div, class: 'btn btn-danger btn-outline' do
          fa_icon('trash')
        end
      end
    else
      link_to_if false, client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking), method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag :div, class: 'btn btn-danger btn-outline disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def client_enrolled_tracking_new_link
    if program_permission_editable?(@enrollment.program_stream_id)
      link_to new_client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, tracking_id: @tracking) do
        content_tag :div, class: 'btn btn-primary btn-outline' do
          t('.new_tracking')
        end
      end
    else
      link_to_if false, new_client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, tracking_id: @tracking) do
        content_tag :div, class: 'btn btn-primary btn-outline disabled' do
          t('.new_tracking')
        end
      end
    end
  end

  def client_enrolled_program_tracking_new_link(id, hidden = false)
    if program_permission_editable?(@enrollment.program_stream_id) && !hidden
      link_to new_client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, tracking_id: id) do
        content_tag :div, class: 'btn btn-primary btn-xs' do
          t('.new_tracking')
        end
      end
    else
      link_to_if false, new_client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, tracking_id: id) do
        content_tag :div, class: 'btn btn-primary btn-xs disabled' do
          t('.new_tracking')
        end
      end
    end
  end
end
