module FormBuilderHelper
  def get_query_string(results, form_type, properties_field)
    results.map do |result|
      condition = ''
      result.map do |h|
        condition = h[:condition]
        if form_type == 'tracking'
          tracking_query_string(h[:id], h[:field], h[:operator], h[:value], h[:type], h[:input], properties_field)
        elsif form_type == 'formbuilder'
          form_builder_query_string(h[:id], h[:field], h[:operator], h[:value], h[:type], h[:input])
        end
      end.join(" #{condition} ")
    end
  end

  def mapping_program_stream_service_param_value(data, field_name=nil, data_mapping=[])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_program_stream_service_param_value(h, field_name=nil, data_mapping)
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

  def program_stream_service_query(id, field_name, operator, value, class_name)
    case operator
    when 'equal'
      "#{class_name}.id = #{value}"
    when 'not_equal'
      "#{class_name}.id != #{value}"
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
      "(#{properties_field} ->> '#{field}')#{'::numeric' if integer?(type) } < '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'less_or_equal'
      "(#{properties_field} ->> '#{field}')#{ '::numeric' if integer?(type) } <= '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'greater'
      "(#{properties_field} ->> '#{field}')#{ '::numeric' if integer?(type) } > '#{value}' AND #{properties_field} ->> '#{field}' != ''"
    when 'greater_or_equal'
      "(#{properties_field} ->> '#{field}')#{ '::numeric' if integer?(type) } >= '#{value}' AND #{properties_field} ->> '#{field}' != ''"
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
        "NOT(#{properties_field} -> '#{field}' ? '') OR (#{properties_field} -> '#{field}') IS NOT NULL"
      end
    when 'between'
      "(#{properties_field} ->> '#{field}')#{ '::numeric' if integer?(type) } BETWEEN '#{value.first}' AND '#{value.last}' AND #{properties_field} ->> '#{field}' != ''"
    end
  end

  def form_builder_query_string(id, field, operator, value, type, input_type, properties_field='')
    value = format_value(value, input_type)
    field = format_value(field, input_type)
    case operator
    when 'equal'
      if input_type == 'text' && field.exclude?('&')
        "(lower(properties ->> '#{field}') = '#{value.downcase}')"
      else
        "(properties -> '#{field}' ? '#{value}')"
      end
    when 'not_equal'
      if input_type == 'text' && field.exclude?('&')
        "(lower(properties ->> '#{field}') != '#{value.downcase}')"
      else
        "(NOT(properties -> '#{field}' ? '#{value}'))"
      end
    when 'less'
      "((properties ->> '#{field}')#{'::numeric' if integer?(type) } < '#{value}' AND properties ->> '#{field}' != '')"
    when 'less_or_equal'
      "((properties ->> '#{field}')#{ '::numeric' if integer?(type) } <= '#{value}' AND properties ->> '#{field}' != '')"
    when 'greater'
      "((properties ->> '#{field}')#{ '::numeric' if integer?(type) } > '#{value}' AND properties ->> '#{field}' != '')"
    when 'greater_or_equal'
      "((properties ->> '#{field}')#{ '::numeric' if integer?(type) } >= '#{value}' AND properties ->> '#{field}' != '')"
    when 'contains'
      "(properties ->> '#{field}' ILIKE '%#{value.squish}%')"
    when 'not_contains'
      "(properties ->> '#{field}' NOT ILIKE '%#{value.squish}%')"
    when 'is_empty'
      if type == 'checkbox'
        "(properties -> '#{field}' ? '')"
      else
        "(properties -> '#{field}' ? '' OR (properties -> '#{field}') IS NULL)"
      end
    when 'is_not_empty'
      if type == 'checkbox'
        "(NOT(properties -> '#{field}' ? ''))"
      else
        "(NOT(properties -> '#{field}' ? '') OR (properties -> '#{field}') IS NOT NULL)"
      end
    when 'between'
      "((properties ->> '#{field}')#{ '::numeric' if integer?(type) } BETWEEN '#{value.first}' AND '#{value.last}' AND properties ->> '#{field}' != '')"
    end
  end

  def map_type_of_services(object)
    if $param_rules.nil?
      program_streams = object.program_streams.joins(:services)
      type_of_services = program_streams.map{|ps| ps.services }.flatten.uniq
    else
      basic_rules = $param_rules['basic_rules']
      basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results = mapping_program_stream_service_param_value(basic_rules)

      query_string = get_program_service_query_string(results)

      program_streams = object.program_streams.joins(:services).where(query_string.reject(&:blank?).join(" AND ")).references(:program_streams)

      sub_results = mapping_service_param_value(basic_rules)
      serivce_query_string = get_program_service_query_string(sub_results)

      type_of_services = program_streams.distinct.map{|ps| ps.services.where(serivce_query_string.reject(&:blank?).join(" AND ")) }.flatten.uniq
    end
  end

  def mapping_service_param_value(data, field_name=nil, data_mapping=[])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_service_param_value(h, field_name=nil, data_mapping)
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

  def mapping_exit_program_date_param_value(data, field_name=nil, data_mapping=[])
    rule_array = []
    data[:rules].each_with_index do |h, index|
      if h.has_key?(:rules)
        mapping_service_param_value(h, field_name=nil, data_mapping)
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

  def exit_program_stream_service_query(id, field, operator, value, type, input_type, properties_field='')
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
      "date(leave_programs.exit_date) IS NULL"
    when 'is_not_empty'
      "date(leave_programs.exit_date) IS NOT NULL"
    when 'between'
      "date(leave_programs.exit_date) BETWEEN '#{value.first}' AND '#{value.last}'"
    end
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
