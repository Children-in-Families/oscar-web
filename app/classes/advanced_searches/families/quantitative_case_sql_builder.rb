module AdvancedSearches
  module Families
    class QuantitativeCaseSqlBuilder

      def initialize(families, rule)
        @families      = families
        field         = rule['field']
        @field_value  = field.split('__').last
        @operator     = rule['operator']
        @value        = rule['value']
      end
  
      def get_sql
        sql_string = 'families.id IN (?)'
        quantitative = QuantitativeType.find_by(name: @field_value)

        if quantitative.select_option?

          families = @families.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: quantitative.id })
  
          case @operator
          when 'equal'
            families = families.where(quantitative_cases: { id: @value })
          when 'not_equal'
            families = families.where.not(quantitative_cases: { id: @value })
          when 'is_empty'
            families = @families.where.not(id: families.ids)
          when 'is_not_empty'
            families
          end
          {id: sql_string, values: families.ids}
        else
          families = @families.joins(:family_quantitative_free_text_cases).where(family_quantitative_cases: { quantitative_type_id: quantitative.id })
  
          case @operator
          when 'equal'
            families = families.where(family_quantitative_cases: { content: @value })
          when 'not_equal'
            families = families.where.not(family_quantitative_cases: { content: @value })
          when 'contains'
            families = families.where("LOWER(family_quantitative_cases.content) LIKE ?", "%#{@value&.downcase}%")
          when 'not_contains'
            families = families.where("family_quantitative_cases.content NOT LIKE ?", "%#{@value.downcase}%")
          when 'is_empty'
            families = @families.where.not(id: families.ids)
          when 'is_not_empty'
            families
          end
  
          { id: sql_string, values: families.ids }
        end
      end
    end
  end
end
