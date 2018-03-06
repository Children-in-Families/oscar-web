module AdvancedSearches
  module Families
    class FamilyAdvancedSearch
      def initialize(basic_rules, families)
        @families = families
        @basic_rules = basic_rules
      end

      def filter
        query_array         = []
        family_base_sql     = AdvancedSearches::Families::FamilyBaseSqlBuilder.new(@families, @basic_rules).generate

        query_array << family_base_sql[:sql_string]
        family_base_values  = family_base_sql[:values].map{ |v| query_array << v }
        @families.where(query_array)
      end
    end
  end
end
