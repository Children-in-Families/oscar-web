module EnrollmentHelper
  def report_link_view(program_stream, entity_type = nil)
    if program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last.try(:status) == 'Exited'
      if entity_type == 'Family'
        link_to t('.view'), report_family_enrollments_path(@programmable, program_stream_id: program_stream)
      end
    end
  end

  def enrollment_new_link(program_stream, entity_type = nil)
    path = entity_type == 'Family' ? new_family_enrollment_path(@programmable, program_stream_id: program_stream.id) : '#'
    if program_permission_editable?(program_stream) && policy(@programmable).create?
      link_to path do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width' do 
          t('.enroll')
        end
      end
    else
      link_to_if false, path do
        content_tag :div, class: 'btn btn-primary btn-xs btn-width disabled' do 
          t('.enroll')
        end
      end
    end
  end

  def cancel_url_link
    if action_name == 'new' || action_name == 'create'
      if params[:family_id]
        link_to t('.cancel'), family_enrollments_path(@programmable), class: 'btn btn-default form-btn'
      end
    else
      path = family_enrollment_path(@programmable, @enrollment, program_stream_id: params[:program_stream_id])
      # link_to t('.cancel'), '#', class: 'btn btn-default form-btn'
      link_to 'To be changed', '#', class: 'btn btn-default form-btn'
    end
  end

  def enrollment_form_action_path
    if action_name.in?(%(new create))
      params[:family_id] ? family_enrolled_programs_path(@programmable) : '#'
    else
      params[:family_id] ? family_enrolled_program_path(@programmable, @enrollment) : '#'
    end
  end

  def cancel_enrollment_form_link
    if params[:action] == 'new' || params[:action] == 'create'
      path = params[:family_id] ? family_enrolled_programs_path(@programmable, program_streams: 'program-streams') : '#'
      link_to t('.cancel'), path, class: 'btn btn-default form-btn'
    elsif params[:action] == 'edit' || params[:action] == 'update'
      path = params[:family_id] ? family_enrolled_program_path(@programmable, @enrollment, program_stream_id: params[:program_stream_id]) : '#'
      link_to t('.cancel'), path, class: 'btn btn-default form-btn'
    end
  end
end
