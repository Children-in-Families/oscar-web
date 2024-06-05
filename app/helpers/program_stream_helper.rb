module ProgramStreamHelper
  def format_rule(rules)
    rules = JSON.parse(rules) if rules['rules'].is_a?(String)
    if rules['rules'].present? && rules['rules'].any?
      forms_prefixed = ['domainscore', 'formbuilder', 'tracking', 'enrollment', 'enrollmentdate', 'programexitdate', 'exitprogramdate', 'exitprogram', 'quantitative']
      rules['rules'].each do |rule|
        if rule['rules'].present?
          format_rule(rule)
        elsif forms_prefixed.any? { |form| rule['id'].include?(form) }
          rule['id'] = rule['id'].gsub(/_/, '__') if rule['id'].exclude?('__')
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
      link_to program_stream_path(program), method: 'delete', data: { confirm: t('.are_you_sure') }, class: 'btn btn-outline btn-danger btn-xs' do
        fa_icon('trash')
      end
    elsif program.client_enrollments.active.empty?
      link_to program_stream_path(program), method: 'delete', data: { confirm: t('.warning_message') }, class: 'btn btn-outline btn-danger btn-xs' do
        fa_icon('trash')
      end
    else
      content_tag(:div, '', class: 'btn btn-outline btn-danger btn-xs disabled') do
        fa_icon('trash')
      end
    end
  end

  def program_stream_redirect_path
    params[:client] == 'true' || params[:entity] == 'true' ? request.referer : program_streams_path
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

    parent_include ? parents + children : children
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

  private

  def form_builder_selection_options(program_stream, program_stream_step = 'trackings')
    field_types = group_field_types(program_stream, program_stream_step)
    @select_field = field_types['select']
    @checkbox_field = field_types['checkbox-group']
    @radio_field = field_types['radio-group']
  end

  def group_field_types(program_stream, program_stream_step)
    group_field_types = Hash.new { |h, k| h[k] = [] }
    group_by_option_type_label = form_builder_group_by_options_type_label(program_stream, program_stream_step)

    if program_stream.attached_to_family? || program_stream.attached_to_community?
      group_selection_field_types = group_selection_field_types_entity(program_stream, program_stream_step)
    else
      group_selection_field_types = group_selection_field_types(program_stream, program_stream_step)
    end

    group_selection_field_types&.compact.each do |selection_field_types|
      group_by_option_type_label.each do |type, labels|
        next unless labels.present?
        labels.each do |label|
          next if selection_field_types[label].blank?
          group_field_types[type] << selection_field_types[label]
        end
      end
    end
    group_field_types = group_field_types.transform_values(&:flatten)
    group_field_types.transform_values(&:uniq)
  end

  def group_selection_field_types(program_stream, program_stream_step)
    group_value_field_types = []
    case program_stream_step
    when 'trackings'
      program_stream.client_enrollments.each do |client_enrollment|
        client_enrollment.client_enrollment_trackings.each do |client_enrollment_tracking|
          choosen_option_form_tracking = client_enrollment_tracking.properties if client_enrollment_tracking.properties.present?
          group_value_field_types << choosen_option_form_tracking
        end
      end
      group_value_field_types
    when 'enrollment'
      program_stream.client_enrollments.each do |client_enrollment|
        choosen_option_form = client_enrollment.properties if client_enrollment.properties.present?
        group_value_field_types << choosen_option_form
      end
      group_value_field_types
    when 'exit_program'
      program_stream.client_enrollments.each do |client_enrollment|
        choosen_option_form_exit_program = client_enrollment.leave_program.properties if client_enrollment.leave_program&.properties.present?
        group_value_field_types << choosen_option_form_exit_program
      end
      group_value_field_types&.reject(&:blank?)
    else
      []
    end
    group_value_field_types
  end

  def group_selection_field_types_entity(program_stream, program_stream_step)
    group_value_field_types = []
    case program_stream_step
    when 'trackings'
      program_stream.enrollments.attached_with(program_stream.entity_type).each do |enrollment|
        enrollment.enrollment_trackings.each do |enrollment_tracking|
          choosen_option_form_tracking = enrollment_tracking.properties if enrollment_tracking.properties.present?
          group_value_field_types << choosen_option_form_tracking
        end
      end
      group_value_field_types
    when 'enrollment'
      program_stream.enrollments.attached_with(program_stream.entity_type).each do |enrollment|
        choosen_option_form = enrollment.properties if enrollment.properties.present?
        group_value_field_types << choosen_option_form
      end
      group_value_field_types
    when 'exit_program'
      program_stream.enrollments.attached_with(program_stream.entity_type).each do |enrollment|
        choosen_option_form_exit_program = enrollment.leave_program.properties if enrollment.leave_program&.properties.present?
        group_value_field_types << choosen_option_form_exit_program
      end
      group_value_field_types&.reject(&:blank?)
    else
      []
    end
    group_value_field_types
  end

  def form_builder_group_by_options_type_label(program_stream, program_stream_step)
    group_options_type_label = Hash.new { |h, k| h[k] = [] }
    form_builder_option = form_builder_options(program_stream, program_stream_step)
    form_builder_option['type'].each_with_index do |type_option_tracking, i|
      group_options_type_label[type_option_tracking] << form_builder_option['label'][i]
    end
    group_options_type_label
  end

  def form_builder_options(program_stream, program_stream_step)
    form_builder_options = Hash.new { |h, k| h[k] = [] }
    case program_stream_step
    when 'trackings'
      program_stream.trackings.each do |tracking|
        tracking.fields.each do |tracking_field|
          tracking_field.each do |k, v|
            next unless k[/^(type|label)$/i]
            form_builder_options[k] << v
          end
        end
      end
      return form_builder_options
    when 'enrollment', 'exit_program'
      program_stream.send(program_stream_step).each do |step|
        step.each do |k, v|
          next unless k[/^(type|label)$/i]
          form_builder_options[k] << v
        end
      end
      return form_builder_options
    else
      {}
    end
    form_builder_options
  end
end
