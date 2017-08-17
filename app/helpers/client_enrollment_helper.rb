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
end
