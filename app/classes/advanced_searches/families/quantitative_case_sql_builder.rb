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
      end
    end
  end
end
