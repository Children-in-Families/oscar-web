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

  def client_enrollment_tracking_edit_link(client, enrollment, enrollment_tracking)
    if program_permission_editable?(enrollment)
      link_to edit_client_client_enrollment_client_enrollment_tracking_path(client, enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking) do
        content_tag :div, class: 'btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_client_client_enrollment_client_enrollment_tracking_path(client, enrollment, enrollment_tracking, tracking_id: enrollment_tracking.tracking) do
        content_tag :div, class: 'btn btn-success btn-outline disabled' do
          fa_icon('pencil')
        end
      end
    end
  end
end
