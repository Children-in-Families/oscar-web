module ClientEnrolledProgramHelper
  def client_enrolled_program_edit_link
    if program_permission_editable?(@program_stream)
      link_to edit_client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream) do
        content_tag :div, class: 'btn btn-success btn-outline' do
          fa_icon('pencil')
        end
      end
    else
      link_to_if false, edit_client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream) do
        content_tag :div, class: 'btn btn-success btn-outline disabled' do
          fa_icon('pencil')
        end
      end
    end
  end

  def client_enrolled_program_destroy_link
    if program_permission_editable?(@program_stream)
      link_to client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream), method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag :div, class: 'btn btn-outline btn-danger' do
          fa_icon('trash')
        end
      end
    else
      link_to_if false, client_client_enrolled_program_path(@client, @client_enrollment, program_stream_id: @program_stream), method: 'delete', data: { confirm: t('.are_you_sure') } do
        content_tag :div, class: 'btn btn-outline btn-danger disabled' do
          fa_icon('trash')
        end
      end
    end
  end

  def program_stream_exit_action(program_stream)
    if program_permission_editable?(program_stream)
      link_to new_client_client_enrolled_program_leave_enrolled_program_path(@client, program_stream.client_enrollments.enrollments_by(@client).order(:created_at).last) do
        content_tag :div, class: 'btn btn-danger btn-xs btn-width' do
          t('.exit')
        end
      end
    else
      link_to_if false, new_client_client_enrolled_program_leave_enrolled_program_path(@client, program_stream.client_enrollments.enrollments_by(@client).order(:created_at).last) do
        content_tag :div, class: 'btn btn-danger btn-xs btn-width disabled' do
          t('.exit')
        end
      end
    end
  end


  def program_stream_tracking_action(program_stream)
    if program_permission_editable?(program_stream)
      link_to client_client_enrolled_program_client_enrolled_program_trackings_path(@client, program_stream.client_enrollments.enrollments_by(@client).order(:created_at).last) do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width' do
          t('.tracking')
        end
      end
    else
      link_to_if false, client_client_enrolled_program_client_enrolled_program_trackings_path(@client, program_stream.client_enrollments.enrollments_by(@client).order(:created_at).last) do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width disabled' do
          t('.tracking')
        end
      end
    end
  end
end