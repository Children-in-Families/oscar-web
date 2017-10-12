module ProgramStreamHelper
  def html_column(full_width)
    full_width ? '' : 'col-md-6'
  end

  def delete_button(program)
    if program.client_enrollments.present?
      content_tag(:div, '', class: 'btn btn-outline btn-danger btn-xs disabled') do
        fa_icon('trash')
      end
    else
      link_to program_stream_path(program), method: 'delete',  data: { confirm: t('.are_you_sure') }, class: 'btn btn-outline btn-danger btn-xs' do
        fa_icon('trash')
      end
    end
  end

  def program_stream_redirect_path
    params[:client] == 'true' ? request.referer : program_streams_path
  end

  def disable_rules_is_used(object)
    if object.is_used?
      "hide-tracking-form"
    end
  end

  def disable_preview_or_show(program_stream)
    if program_stream.ngo_name == current_organization.full_name && !(ProgramStreamPermission.find_by(program_stream_id: program_stream.id, user_id: current_user.id).try(:readable?)) && !(current_user.admin?)
      'disabled'
    end
  end

  def disable_edit(program_stream)
    unless current_user.admin?
      unless ProgramStreamPermission.find_by(program_stream_id: program_stream.id, user_id: current_user.id).try(:editable?)
        'disabled'
      end
    end
  end
end
