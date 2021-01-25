module AdvancedSearches
  module Communities
    class CommunityAdvancedSearch
      def initialize(basic_rules, communities)
        @communities = communities
        @basic_rules = basic_rules
      end

      def filter
        query_array        = []
        community_base_sql = AdvancedSearches::Communities::CommunityBaseSqlBuilder.new(@communities, @basic_rules).generate

        query_array << community_base_sql[:sql_string]
        community_base_values  = community_base_sql[:values].map{ |v| query_array << v }
        @communities.where(query_array)
      end
    end
  end
end
