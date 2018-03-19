module AdvancedSearches
  module Partners
    class PartnerAssociationFilter
      def initialize(partners, field, operator, values)
        @partners  = partners
        @field    = field
        @operator = operator
        @value   = values
      end

      def get_sql
        sql_string = 'partners.id IN (?)'
        case @field
        when 'form_title'
          values = form_title_field_query
        end
        { id: sql_string, values: values }
      end

      private

      def form_title_field_query
        partners = @partners.joins(:custom_fields)
        case @operator
        when 'equal'
          partners = partners.where('custom_fields.id = ?', @value)
        when 'not_equal'
          partners = partners.where.not('custom_fields.id = ?', @value)
        when 'is_empty'
          partners = @partners.where.not(id: partners.ids)
        when 'is_not_empty'
          partners = @partners.where(id: partners.ids)
        end
        partners.uniq.ids
      end
    end
  end
end
