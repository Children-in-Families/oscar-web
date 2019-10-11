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

  def tracking_query_string(id, field, operator, value, type, input_type, properties_field)
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
    case operator
    when 'equal'
      if input_type == 'text' && field.exclude?('&')
        "lower(properties ->> '#{field}') = '#{value.downcase}'"
      else
        "properties -> '#{field}' ? '#{value}'"
      end
    when 'not_equal'
      if input_type == 'text' && field.exclude?('&')
        "lower(properties ->> '#{field}') != '#{value.downcase}'"
      else
        "NOT(properties -> '#{field}' ? '#{value}')"
      end
    when 'less'
      "(properties ->> '#{field}')#{'::numeric' if integer?(type) } < '#{value}' AND properties ->> '#{field}' != ''"
    when 'less_or_equal'
      "(properties ->> '#{field}')#{ '::numeric' if integer?(type) } <= '#{value}' AND properties ->> '#{field}' != ''"
    when 'greater'
      "(properties ->> '#{field}')#{ '::numeric' if integer?(type) } > '#{value}' AND properties ->> '#{field}' != ''"
    when 'greater_or_equal'
      "(properties ->> '#{field}')#{ '::numeric' if integer?(type) } >= '#{value}' AND properties ->> '#{field}' != ''"
    when 'contains'
      "properties ->> '#{field}' ILIKE '%#{value.squish}%'"
    when 'not_contains'
      "properties ->> '#{field}' NOT ILIKE '%#{value.squish}%'"
    when 'is_empty'
      if type == 'checkbox'
        "properties -> '#{field}' ? ''"
      else
        "properties -> '#{field}' ? '' OR (properties -> '#{field}') IS NUL"
      end
    when 'is_not_empty'
      if type == 'checkbox'
        "NOT(properties -> '#{field}' ? '')"
      else
        "NOT(properties -> '#{field}' ? '') OR (properties -> '#{field}') IS NOT NULL"
      end
    when 'between'
      "(properties ->> '#{field}')#{ '::numeric' if integer?(type) } BETWEEN '#{value.first}' AND '#{value.last}' AND properties ->> '#{field}' != ''"
    end
  end

  def integer?(type)
    type == 'integer'
  end
end
