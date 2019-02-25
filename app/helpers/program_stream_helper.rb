module ProgramStreamHelper

  def format_rule(rules)
    if rules['rules'].present? && rules['rules'].any?
      rules['rules'].each do |rule|
        if rule['rules'].present?
          format_rule(rule)
        elsif rule['id'].include?('domainscore')
          rule['id']    = rule['id'].gsub(/_/, '__') if rule['id'].exclude?('__')
          rule['field'] = rule['field'].gsub(/_/, '__') if rule['field'].exclude?('__')
        end
      end
    end
    rules
  end

  def html_column(full_width)
    full_width ? '' : 'col-md-6'
  end

  def delete_button(program)
    if program.client_enrollments.empty?
      link_to program_stream_path(program), method: 'delete',  data: { confirm: t('.are_you_sure') }, class: 'btn btn-outline btn-danger btn-xs' do
        fa_icon('trash')
      end
    elsif program.client_enrollments.active.empty?
      link_to program_stream_path(program), method: 'delete',  data: { confirm: t('.warning_message') }, class: 'btn btn-outline btn-danger btn-xs' do
        fa_icon('trash')
      end
    else
      content_tag(:div, '', class: 'btn btn-outline btn-danger btn-xs disabled') do
        fa_icon('trash')
      end
    end
  end

  def program_stream_redirect_path
    params[:client] == 'true' ? request.referer : program_streams_path
  end

  def format_placeholder(value)
    value.gsub('&amp;qoute;', '&quot;').html_safe if value.present?
  end
end
