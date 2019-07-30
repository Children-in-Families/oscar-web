module ProgramStreamHelper

  def format_rule(rules)
    if rules['rules'].present? && rules['rules'].any?
      forms_prefixed = ['domainscore', 'formbuilder', 'tracking', 'enrollment', 'enrollmentdate', 'programexitdate', 'exitprogram', 'quantitative']
      rules['rules'].each do |rule|
        if rule['rules'].present?
          format_rule(rule)
        elsif forms_prefixed.any?{ |form| rule['id'].include?(form) }
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
    value.gsub('-', ' ').gsub('&amp;qoute;', '&quot;').html_safe if value.present?
  end

  def services(parent_include = true)
    service_parents = Service.only_parents
    parents = service_parents.map do |service|
      [service.name, service.id]
    end

    service_children = Service.only_children
    children = []

    ids = service_children.ids
    children = find_children(service_parents, ids, children)

    results = parent_include ?  parents + children : children
  end

  def find_children(service_parents, ids, children)
    the_ids = ids
    return children if ids.blank?
    service_parents.ids.map do |parent_id|
      child = Service.where(id: the_ids).find_by(parent_id: parent_id)
      if child
        children << [child.name, child.id]
        the_ids.delete(child.id)
      else
        children << ['', '']
      end
    end
    find_children(service_parents, the_ids, children)
  end
end
