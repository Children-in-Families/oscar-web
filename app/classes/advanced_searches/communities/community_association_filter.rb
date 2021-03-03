module AdvancedSearches
  module Communities
    class CommunityAssociationFilter
      def initialize(communities, field, operator, values)
        @communities  = communities
        @field    = field
        @operator = operator
        @value   = values
      end

      def get_sql
        sql_string = 'communities.id IN (?)'
        case @field
        when 'client_id'
          values = clients
        when 'case_workers'
          values = case_worker_field_query
        when 'gender'
          values = get_community_member_gender
        when 'date_of_birth'
          if @operator != 'between'
            values = query_community_members(@value.to_date)
          else
            values = query_community_members(nil, @value.map(&:to_date))
          end
        when /count/
          if @operator != 'between'
            values = query_community_members(@value.to_i)
          else
            values = query_community_members(nil, @value.map(&:to_i))
          end
        end
        { id: sql_string, values: values }
      end

      private

      def clients
        communities = @communities
        case @operator
        when 'equal'
          communities = communities.joins(:clients).where('children && ARRAY[?]', @value.to_i)
        when 'not_equal'
          communities = communities.joins(:clients).where.not('children && ARRAY[?]', @value.to_i)
        when 'is_empty'
          communities = communities.where(children: '{}')
        when 'is_not_empty'
          communities = communities.where.not(children: '{}')
        end
        communities.ids
      end

      def case_worker_field_query
        community_ids = []
        case @operator
        when 'equal'
          community_ids = Case.joins(:community).non_emergency.active.where(user_id: @value).pluck(:community_id).uniq
        when 'not_equal'
          community_ids = Case.joins(:community).where.not(cases: { case_type: 'EC', exited: true, user_id: @value }).pluck(:community_id).uniq
        when 'is_empty'
          community_ids = @communities.where.not(id: Case.joins(:community).where.not(cases: { case_type: 'EC', exited: true }).pluck(:community_id).uniq).ids
        when 'is_not_empty'
          community_ids = @communities.where(id: Case.joins(:community).where.not(cases: { case_type: 'EC', exited: true }).pluck(:community_id).uniq).ids
        end
        community_ids
      end

      def get_community_member_gender
        communities = @communities.joins(:community_members).distinct
        case @operator
        when 'equal'
          communities = communities.where('community_members.gender = ?', @value)
        when 'not_equal'
          communities = communities.where('community_members.gender != ?', @value)
        when 'is_empty'
          communities = Community.includes(:community_members).where('community_members.gender IS NULL')
        when 'is_not_empty'
          communities = communities.where('community_members.gender IS NOT NULL')
        end
        communities.ids
      end

      def query_community_members(value, values = [])
        communities = @communities.joins(:community_members).distinct
        if @field == 'date_of_birth'
          sql = "date(community_members.date_of_birth)"
        else
          sql = "community_members.#{@field}"
        end

        case @operator
        when 'equal'
          communities = communities.where("#{sql} = ?", value)
        when 'not_equal'
          communities = communities.where("#{sql} != ? OR #{sql} IS NULL", value)
        when 'less'
          communities = communities.where("#{sql} < ?", value)
        when 'less_or_equal'
          communities = communities.where("#{sql} <= ?", value)
        when 'greater'
          communities = communities.where("#{sql} > ?", value)
        when 'greater_or_equal'
          communities = communities.where("#{sql} >= ?", value)
        when 'between'
          communities = communities.where("#{sql} BETWEEN ? AND ? ", values[0], values[1])
        when 'is_empty'
          communities = Community.includes(:community_members).where("community_members.#{@field} = NULL")
        when 'is_not_empty'
          communities = communities.where("community_members.#{@field} != NULL")
        end
        communities.ids
      end
    end
  end
end
