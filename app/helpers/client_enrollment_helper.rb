module ClientEnrollmentHelper
  def view_report_link(program_stream)
    if program_stream.client_enrollments.present?
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
end