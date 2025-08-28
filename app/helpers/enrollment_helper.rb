module EnrollmentHelper
  def report_link_view(program_stream)
    if program_stream.enrollments.enrollments_by(@programmable).order(:created_at).last.try(:status) == 'Exited'
      if @entity_type == 'Family'
        link_to t('.view'), report_family_enrollments_path(@programmable, program_stream_id: program_stream)
      elsif @entity_type == 'Community'
        link_to t('.view'), report_community_enrollments_path(@programmable, program_stream_id: program_stream)
      end
    end
  end

  def enrollment_new_link(program_stream)
    if @entity_type == 'Family'
      path = new_family_enrollment_path(@programmable, program_stream_id: program_stream.id)
    elsif @entity_type == 'Community'
      path = new_community_enrollment_path(@programmable, program_stream_id: program_stream.id)
    else
      path = '#'
    end

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

  def enrollment_edit_link
    if params[:family_id]
      path = edit_family_enrollment_path(@programmable, @enrollment, program_stream_id: @program_stream)
    elsif params[:community_id]
      path = edit_community_enrollment_path(@programmable, @enrollment, program_stream_id: @program_stream)
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

  def enrollment_destroy_link
    if params[:family_id]
      path = family_enrollment_path(@programmable, @enrollment, program_stream_id: @program_stream)
    elsif params[:community_id]
      path = community_enrollment_path(@programmable, @enrollment, program_stream_id: @program_stream)
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

  def cancel_url_link
    if action_name == 'new' || action_name == 'create'
      if params[:family_id]
        link_to t('.cancel'), family_enrollments_path(@programmable), class: 'btn btn-default form-btn'
      elsif params[:community_id]
        link_to t('.cancel'), community_enrollments_path(@programmable), class: 'btn btn-default form-btn'
      end
    else
      if params[:family_id]
        link_to t('.cancel'), family_enrollment_path(@programmable, @enrollment, program_stream_id: params[:program_stream_id]), class: 'btn btn-default form-btn'
      elsif params[:community_id]
        link_to t('.cancel'), community_enrollment_path(@programmable, @enrollment, program_stream_id: params[:program_stream_id]), class: 'btn btn-default form-btn'
      end
    end
  end

  def enrollment_form_action_path
    if action_name.in?(%(new create))
      params[:family_id] ? family_enrolled_programs_path(@programmable) : params[:community_id] ? community_enrolled_programs_path(@programmable) : '#'
    else
      params[:family_id] ? family_enrolled_program_path(@programmable, @enrollment) : params[:community_id] ? community_enrolled_program_path(@programmable, @enrollment) : '#'
    end
  end

  def cancel_enrollment_form_link
    if params[:action] == 'new' || params[:action] == 'create'
      if params[:family_id]
        path = family_enrolled_programs_path(@programmable, program_streams: 'program-streams')
      elsif params[:community_id]
        path = community_enrolled_programs_path(@programmable, program_streams: 'program-streams')
      else
        path = '#'
      end
      link_to t('.cancel'), path, class: 'btn btn-default form-btn'
    elsif params[:action] == 'edit' || params[:action] == 'update'
      if params[:family_id]
        path = family_enrolled_program_path(@programmable, @enrollment, program_stream_id: params[:program_stream_id])
      elsif params[:community_id]
        path = community_enrolled_program_path(@programmable, @enrollment, program_stream_id: params[:program_stream_id])
      else
        path = '#'
      end
      link_to t('.cancel'), path, class: 'btn btn-default form-btn'
    end
  end
end
