module AdvancedSearches
  module Partners
    class PartnerAdvancedSearch
      def initialize(basic_rules, partners)
        @partners            = partners
        @basic_rules        = basic_rules
      end

      def filter
        query_array         = []
        partner_base_sql     = AdvancedSearches::Partners::PartnerBaseSqlBuilder.new(@partners, @basic_rules).generate

        query_array << partner_base_sql[:sql_string]
        family_base_values  = partner_base_sql[:values].map{ |v| query_array << v }
        @partners.where(query_array)
      end
    end
  end
end
