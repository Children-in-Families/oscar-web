module AdvancedSearches
  class QuantitativeCaseSqlBuilder
    attr_reader :klass_name
    def initialize(objects, rule, klass_name = 'clients')
      @objects      = objects
      @klass_name   = klass_name
      field         = rule['field']
      @field_value  = field.split('__').last
      @operator     = rule['operator']
      @value        = rule['value']
    end

    def get_sql
      sql_string = "#{klass_name}.id IN (?)"
      quantitative = QuantitativeType.find_by(name: @field_value)

      if quantitative.select_option?

        objects = @objects.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: quantitative.id })

        case @operator
        when 'equal'
          objects = objects.where(quantitative_cases: { id: @value })
        when 'not_equal'
          objects = objects.where.not(quantitative_cases: { id: @value })
        when 'is_empty'
          objects = @objects.where.not(id: objects.ids)
        when 'is_not_empty'
          objects
        end
        {id: sql_string, values: objects.ids}
      else
        if klass_name == 'clients'
          objects = @objects.joins(:client_quantitative_free_text_cases).where(client_quantitative_cases: { quantitative_type_id: quantitative.id })

          case @operator
          when 'equal'
            objects = objects.where(client_quantitative_cases: { content: @value })
          when 'not_equal'
            objects = objects.where.not(client_quantitative_cases: { content: @value })
          when 'contains'
            objects = objects.where("LOWER(client_quantitative_cases.content) LIKE ?", "%#{@value&.downcase}%")
          when 'not_contains'
            objects = objects.where("client_quantitative_cases.content NOT LIKE ?", "%#{@value.downcase}%")
          when 'is_empty'
            objects = @objects.where.not(id: objects.ids)
          when 'is_not_empty'
            objects
          end
        elsif klass_name == 'communities'
          objects = @objects.joins(:community_quantitative_free_text_cases).where(community_quantitative_cases: { quantitative_type_id: quantitative.id })

          case @operator
          when 'equal'
            objects = objects.where(community_quantitative_cases: { content: @value })
          when 'not_equal'
            objects = objects.where.not(community_quantitative_cases: { content: @value })
          when 'contains'
            objects = objects.where("LOWER(community_quantitative_cases.content) LIKE ?", "%#{@value&.downcase}%")
          when 'not_contains'
            objects = objects.where("community_quantitative_cases.content NOT LIKE ?", "%#{@value.downcase}%")
          when 'is_empty'
            objects = @objects.where.not(id: objects.ids)
          when 'is_not_empty'
            objects
          end
        end

        { id: sql_string, values: objects.ids }
      end
    end
  end
end
