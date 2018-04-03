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
        when 'form_title'
          values = form_title_field_query
        when 'case_workers'
          values = case_worker_field_query
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

      def form_title_field_query
        families = @families.joins(:custom_fields)
        case @operator
        when 'equal'
          families = families.where('custom_fields.id = ?', @value)
        when 'not_equal'
          families = families.where.not('custom_fields.id = ?', @value)
        when 'is_empty'
          families = @families.where.not(id: families.ids)
        when 'is_not_empty'
          families = @families.where(id: families.ids)
        end
        families.uniq.ids
      end

      def case_worker_field_query
        family_ids = []
        case @operator
        when 'equal'
          family_ids = Case.joins(:family).non_emergency.active.where(user_id: @value).pluck(:family_id).uniq
        when 'not_equal'
          family_ids = Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true, user_id: @value }).pluck(:family_id).uniq
        when 'is_empty'
          family_ids = @families.where.not(id: Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true }).pluck(:family_id).uniq).ids
        when 'is_not_empty'
          family_ids = @families.where(id: Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true }).pluck(:family_id).uniq).ids
        end
        family_ids
      end
    end
  end
end
