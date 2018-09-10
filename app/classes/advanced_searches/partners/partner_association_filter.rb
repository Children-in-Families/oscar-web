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
        # sql_string = 'partners.id IN (?)'
        # case @field
      end

      private
    end
  end
end
