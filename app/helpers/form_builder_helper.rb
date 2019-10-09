module FormBuilderHelper
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
        properties_result = client_enrollment_trackings.where.not("lower(#{properties_field} ->> '#{@field}') = '#{@value}' ")
      else
        properties_result = client_enrollment_trackings.where.not("#{properties_field} -> '#{@field}' ? '#{@value}' ")
      end
    when 'less'
      properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{'::numeric' if integer? } < '#{@value}' AND #{properties_field} ->> '#{@field}' != '' ")
    when 'less_or_equal'
      properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{ '::numeric' if integer? } <= '#{@value}' AND #{properties_field} ->> '#{@field}' != '' ")
    when 'greater'
      properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{ '::numeric' if integer? } > '#{@value}' AND #{properties_field} ->> '#{@field}' != '' ")
    when 'greater_or_equal'
      properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{ '::numeric' if integer? } >= '#{@value}' AND #{properties_field} ->> '#{@field}' != '' ")
    when 'contains'
      properties_result = client_enrollment_trackings.where("#{properties_field} ->> '#{@field}' ILIKE '%#{@value.squish}%' ")
    when 'not_contains'
      properties_result = client_enrollment_trackings.where("#{properties_field} ->> '#{@field}' NOT ILIKE '%#{@value.squish}%' ")
    when 'is_empty'
      if type == 'checkbox'
        properties_result = client_enrollment_trackings.where.not("#{properties_field} -> '#{@field}' ? ''")
        client_ids        = properties_result.pluck(:client_id)
      else
        properties_result = client_enrollment_trackings.where.not("#{properties_field} -> '#{@field}' ? '' OR (#{properties_field} -> '#{@field}') IS NULL")
        client_ids        = properties_result.pluck(:client_id)
      end
      client_ids          = Client.where.not(id: client_ids).ids
      return {id: sql_string, values: client_ids}
    when 'is_not_empty'
      if type == 'checkbox'
        properties_result = client_enrollment_trackings.where.not("#{properties_field} -> '#{@field}' ? ''")
      else
        properties_result = client_enrollment_trackings.where.not("#{properties_field} -> '#{@field}' ? '' OR (#{properties_field} -> '#{@field}') IS NULL")
      end
    when 'between'
      "(#{properties_field} ->> '#{field}')#{ '::numeric' if type == 'integer' } BETWEEN '#{value.first}' AND '#{value.last}' AND #{properties_field} ->> '#{field}' != ''"
    end
  end
end
