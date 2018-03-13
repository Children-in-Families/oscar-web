module AdvancedSearches
  module Families
    class FamilyAssociationFilter
      def initialize(families, field, operator, values)
        @families  = families
        @field    = field
        @operator = operator
        @value   = values
      end

      def get_sql
        sql_string = 'families.id IN (?)'
        case @field
        when 'client_id'
          values = clients
        end
        { id: sql_string, values: values }
      end

      private

      def clients
        families = @families.joins(:clients)
        case @operator
        when 'equal'
          families = families.where('children && ARRAY[?]', @value.to_i)
        when 'not_equal'
          families = families.where.not('children && ARRAY[?]', @value.to_i)
        when 'is_empty'
          families = families.where(children: [])
        when 'is_not_empty'
          families = families.where.not(children: [])
        end
        families.ids
      end
    end
  end
end
