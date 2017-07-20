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

  def used_tracking?(tracking)
    tracking.client_enrollment_trackings.present?
  end
end
