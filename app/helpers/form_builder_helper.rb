module FormBuilderHelper
  def get_query_string(results, form_type, properties_field, program_name = nil)
    results.map do |result|
      condition = ''
      result.map do |h|
        condition = h[:condition]
        if form_type == 'tracking'
          field = h[:field].split('__').last
          tracking_query_string(h[:id], field, h[:operator], h[:value], h[:type], h[:input], properties_field)
        elsif form_type == 'formbuilder'
          form_builder_query_string(h[:id], h[:field], h[:operator], h[:value], h[:type], h[:input], properties_field)
        elsif form_type == 'custom_data'
          form_builder_query_string(h[:id], h[:id].split('__').last, h[:operator], h[:value], h[:type], h[:input], properties_field)
        elsif form_type == 'active_program_stream'
          program_stream_service_query(h[:id], h[:field], h[:operator], h[:value], 'program_streams')
        end
      end.join(" #{condition} ")
    end
  end

  def mapping_program_stream_service_param_value(data, field_name = nil, data_mapping = [])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_program_stream_service_param_value(h, field_name = nil, data_mapping)
      end
      if field_name.nil?
        next if !(h[:id] =~ /^(active_program_stream|type_of_service)/i)
      else
        next if h[:id] != field_name
      end
      h[:condition] = data[:condition]
      rule_array << h
    end
    data_mapping << rule_array
  end

  def mapping_allowed_param_value(data, field_names, data_mapping = [])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_allowed_param_value(h, field_names, data_mapping)
      else
        next if !(field_names.include?(h[:id]))
        h[:condition] = data[:condition]
        rule_array << h
      end
    end
    data_mapping << rule_array
  end

  def get_program_service_query_string(results)
    results.map do |result|
      condition = ''
      result.map do |h|
        condition = h[:condition]
        class_name = h[:id] == 'active_program_stream' ? 'program_streams' : 'services'
        program_stream_service_query(h[:id], h[:field], h[:operator], h[:value], class_name)
      end.join(" #{condition} ")
    end
  end

  def get_any_query_string(results, class_name)
    results.map do |result|
      condition = ''
      result.map do |h|
        condition = h[:condition]
        klass_name = h[:id] == 'protection_concern_id' ? 'call_protection_concerns' : class_name
        general_query(h[:id], h[:field], h[:operator], h[:value], h[:type], klass_name)
      end.join(" #{condition} ")
    end
  end

  def program_stream_service_query(id, field_name, operator, value, class_name)
    case operator
    when 'equal'
      "#{class_name}.id = #{value}"
    when 'not_equal'
      if class_name == 'program_streams'
        sql = "#{class_name}.id = #{value} OR #{class_name}.id IS NULL"
        client_ids = Client.joins(:program_streams).where(sql).distinct.ids
        if client_ids.present?
          "clients.id NOT IN (#{client_ids.join(',')}) OR #{class_name}.id IS NULL"
        else
          "#{class_name}.id != #{value} OR #{class_name}.id IS NULL"
        end
      else
        "#{class_name}.id != #{value} OR #{class_name}.id IS NULL"
      end
    when 'is_empty'
      "#{class_name}.id IS NULL"
    when 'is_not_empty'
      "#{class_name}.id IS NOT NULL"
    end
  end

  def tracking_query_string(id, field, operator, value, type, input_type, properties_field)
    value = format_value(value, input_type)
    field = format_value(field, input_type)
    case operator
    when 'equal'
      if input_type == 'text' && field.exclude?('&')
        "lower(#{properties_field} ->> '#{field}') = '#{value}'"
      else
        "#{properties_field} -> '#{field}' ? '#{value}'"
      end
    when 'not_equal'
      if input_type == 'text' && field.exclude?('&')
        "NOT(lower(#{properties_field} ->> '#{field}') = '#{value}')"
      else
        "NOT(#{properties_field} -> '#{field}' ? '#{value}')"
      end
    when 'less'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} < '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'less_or_equal'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} <= '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'greater'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} > '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'greater_or_equal'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} >= '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'contains'
      "#{properties_field} ->> '#{field}' ILIKE '%#{value.squish}%'"
    when 'not_contains'
      "#{properties_field} ->> '#{field}' NOT ILIKE '%#{value.squish}%'"
    when 'is_empty'
      if type == 'checkbox'
        "#{properties_field} -> '#{field}' ? ''"
      else
        "#{properties_field} -> '#{field}' ? '' OR (#{properties_field} -> '#{field}') IS NULL"
      end
    when 'is_not_empty'
      if type == 'checkbox'
        "NOT(#{properties_field} -> '#{field}' ? '')"
      else
        "#{properties_field} -> '#{field}' IS NOT NULL AND #{properties_field} ->> '#{field}' <> '' AND #{properties_field} ->> '#{field}' <> '{}' AND #{properties_field} ->> '#{field}' <> '[]'"
      end
    when 'between'
      "((#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} BETWEEN '#{value.first}' AND '#{value.last}' AND #{properties_field} ->> '#{field}' != '')"
    end
  end

  def form_builder_query_string(id, field, operator, value, type, input_type, properties_field = 'properties')
    value = format_value(value, input_type)
    field = format_value(field, input_type)
    case operator
    when 'equal'
      if input_type == 'text' && field.exclude?('&')
        "lower(#{properties_field} ->> '#{field}') = '#{value.downcase}'"
      else
        "#{properties_field} -> '#{field}' ? '#{value}'"
      end
    when 'not_equal'
      if input_type == 'text' && field.exclude?('&')
        "lower(#{properties_field} ->> '#{field}') != '#{value.downcase}'"
      else
        "NOT(#{properties_field} -> '#{field}' ? '#{value}')"
      end
    when 'less'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} < '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'less_or_equal'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} <= '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'greater'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} > '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'greater_or_equal'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} >= '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'contains'
      "#{properties_field} ->> '#{field}' ILIKE '%#{value.squish}%'"
    when 'not_contains'
      "#{properties_field} ->> '#{field}' NOT ILIKE '%#{value.squish}%'"
    when 'is_empty'
      "(#{properties_field} ->> '#{field}') IS NULL OR (#{properties_field} ->> '#{field}') = '' OR (#{properties_field} ->> '#{field}') = '[\"\"]'"
    when 'is_not_empty'
      "(#{properties_field} ->> '#{field}') IS NOT NULL AND (#{properties_field} ->> '#{field}') <> '' AND (#{properties_field} ->> '#{field}') <> '[\"\"]'"
    when 'between'
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type)} BETWEEN '#{value.first}' AND '#{value.last}' AND #{properties_field} ->> '#{field}' != ''"
    end
  end

  def general_query(id, field, operator, value, type, class_name)
    field_name = (id == 'case_note_date' || id == 'no_case_note_date') ? 'meeting_date' : id
    field_name = field_name == 'case_note_type' ? 'interaction_type' : field_name
    field_name = field_name[/quantitative__\d+/].present? ? 'id' : field_name
    value = !value.is_a?(Array) && type == 'string' ? value.downcase : value

    lower_field_name = string_field(type, field_name, value) ? "LOWER(#{class_name}.#{field_name})" : "#{class_name}.#{field_name}"
    table_name_field_name = ['start_datetime'].include?(field_name) ? "DATE_PART('hour', #{class_name}.#{field_name})" : lower_field_name
    table_name_field_name = ['date_of_call', 'meeting_date'].include?(field_name) ? "DATE(#{class_name}.#{field_name})" : table_name_field_name

    case operator
    when 'equal'
      if value == 'true'
        "#{table_name_field_name} = #{value}"
      elsif value == 'false'
        "#{table_name_field_name} = #{value} OR #{table_name_field_name} IS NULL"
      else
        "#{table_name_field_name} = '#{value}'"
      end
    when 'not_equal'
      if value == 'true'
        "#{table_name_field_name} != #{value}"
      elsif value == 'false'
        "#{table_name_field_name} != #{value} OR #{table_name_field_name} IS NOT NULL"
      else
        "#{table_name_field_name} != '#{value}'"
      end
    when 'less'
      "#{table_name_field_name} < '#{value}' AND #{lower_field_name} IS NOT NULL"
    when 'less_or_equal'
      "#{table_name_field_name} <= '#{value}' AND #{lower_field_name} IS NOT NULL"
    when 'greater'
      "#{table_name_field_name} > '#{value}' AND #{lower_field_name} IS NOT NULL"
    when 'greater_or_equal'
      "#{table_name_field_name} >= '#{value}' AND #{lower_field_name} IS NOT NULL"
    when 'contains'
      "#{table_name_field_name} ILIKE '%#{value.squish}%' AND #{lower_field_name} IS NOT NULL"
    when 'not_contains'
      "#{table_name_field_name} NOT ILIKE '%#{value.squish}%' OR #{lower_field_name} IS NULL"
    when 'is_empty'
      if field_name[/datetime|meeting_date|case_note_date/]
        "#{lower_field_name} IS NULL"
      elsif field_name[/called_before|childsafe|answered_call|requested_update|not_a_phone_call/]
        "#{table_name_field_name} IS NULL"
      else
        "#{table_name_field_name} = '' OR #{table_name_field_name} IS NULL"
      end
    when 'is_not_empty'
      if field_name[/date/]
        "#{lower_field_name} IS NOT NULL"
      elsif field_name[/called_before|childsafe|answered_call|requested_update|not_a_phone_call/]
        "#{table_name_field_name} IS NOT NULL"
      else
        "#{table_name_field_name} != '' AND #{lower_field_name} IS NOT NULL"
      end
    when 'between'
      "#{table_name_field_name} BETWEEN '#{value.first}' AND '#{value.last}' AND #{table_name_field_name} IS NOT NULL"
    end
  end

  def string_field(type, field_name, value)
    type == 'string' && field_name.exclude?('datetime') && ['true', 'false'].exclude?(value) && field_name[/(.*id)$/].blank? && %w(called_before childsafe answered_call requested_update not_a_phone_call).exclude?(field_name)
  end

  def map_type_of_services(object)
    if $param_rules.nil?
      return_default_client_type_of_services(object)
    else
      basic_rules = $param_rules['basic_rules']
      basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results = mapping_program_stream_service_param_value(basic_rules)
      return return_default_client_type_of_services(object) if results.flatten.blank?
      query_string = get_program_service_query_string(results)

      program_streams = object.program_streams.joins(:services).where(query_string.reject(&:blank?).join(' AND ')).references(:program_streams)

      sub_results = mapping_service_param_value(basic_rules)
      serivce_query_string = get_program_service_query_string(sub_results)

      type_of_services = program_streams.distinct.map { |ps| ps.services.where(serivce_query_string.reject(&:blank?).join(' AND ')) }.flatten.uniq
    end
  end

  def return_default_client_type_of_services(object)
    program_streams = object.program_streams.joins(:services)
    type_of_services = program_streams.map { |ps| ps.services }.flatten.uniq
  end

  def mapping_service_param_value(data, field_name = nil, data_mapping = [])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_service_param_value(h, field_name = nil, data_mapping)
      end
      if field_name.nil?
        next if !(h[:id] =~ /^(type_of_service)/i)
      else
        next if h[:id] != field_name
      end
      h[:condition] = data[:condition]
      rule_array << h
    end
    data_mapping << rule_array
  end

  def mapping_exit_program_date_param_value(data, field_name = nil, data_mapping = [])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_service_param_value(h, field_name = nil, data_mapping)
      end
      if field_name.nil?
        next if !(h[:id] =~ /^(programexitdate|exitprogramdate)/i)
      else
        next if h[:id] != field_name
      end
      h[:condition] = data[:condition]
      rule_array << h
    end
    data_mapping << rule_array
  end

  def get_exit_program_date_query_string(results)
    results.map do |result|
      condition = ''
      result.map do |h|
        condition = h[:condition]
        exit_program_stream_service_query(h[:id], h[:field], h[:operator], h[:value], h[:type], h[:input])
      end.join(" #{condition} ")
    end
  end

  def exit_program_stream_service_query(id, field, operator, value, type, input_type, properties_field = '')
    case operator
    when 'equal'
      "date(leave_programs.exit_date) = '#{value}'"
    when 'not_equal'
      "date(leave_programs.exit_date) != '#{value}'"
    when 'less'
      "date(leave_programs.exit_date) < '#{value}'"
    when 'less_or_equal'
      "date(leave_programs.exit_date) <= '#{value}'"
    when 'greater'
      "date(leave_programs.exit_date) > '#{value}'"
    when 'greater_or_equal'
      "date(leave_programs.exit_date) >= '#{value}'"
    when 'is_empty'
      'date(leave_programs.exit_date) IS NULL'
    when 'is_not_empty'
      'date(leave_programs.exit_date) IS NOT NULL'
    when 'between'
      "date(leave_programs.exit_date) BETWEEN '#{value.first}' AND '#{value.last}'"
    end
  end

  def custom_form_with_has_form(object, fields)
    object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client' })
  end

  private

  def format_value(value, input_type)
    type_format = ['select', 'radio-group', 'checkbox-group']
    if type_format.include?(input_type)
      value = value.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
    end

    value.is_a?(Array) || value.is_a?(Fixnum) ? value : value.gsub("'", "''")
  end

  def integer?(type)
    type == 'integer'
  end
end
