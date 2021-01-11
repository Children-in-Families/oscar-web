# module AdvancedSearches
#   module Communities
#     class CommunityAssociationFilter
#       def initialize(communities, field, operator, values)
#         @communities  = communities
#         @field    = field
#         @operator = operator
#         @value   = values
#       end

#       def get_sql
#         sql_string = 'communities.id IN (?)'
#         case @field
#         when 'client_id'
#           values = clients
#         when 'case_workers'
#           values = case_worker_field_query
#         when 'gender'
#           values = get_community_member_gender
#         when 'date_of_birth'
#           values = get_community_member_dob
#         end
#         { id: sql_string, values: values }
#       end

#       private

#       def clients
#         communities = @communities
#         case @operator
#         when 'equal'
#           communities = communities.joins(:clients).where('children && ARRAY[?]', @value.to_i)
#         when 'not_equal'
#           communities = communities.joins(:clients).where.not('children && ARRAY[?]', @value.to_i)
#         when 'is_empty'
#           communities = communities.where(children: '{}')
#         when 'is_not_empty'
#           communities = communities.where.not(children: '{}')
#         end
#         communities.ids
#       end

#       def case_worker_field_query
#         community_ids = []
#         case @operator
#         when 'equal'
#           community_ids = Case.joins(:community).non_emergency.active.where(user_id: @value).pluck(:community_id).uniq
#         when 'not_equal'
#           community_ids = Case.joins(:community).where.not(cases: { case_type: 'EC', exited: true, user_id: @value }).pluck(:community_id).uniq
#         when 'is_empty'
#           community_ids = @communities.where.not(id: Case.joins(:community).where.not(cases: { case_type: 'EC', exited: true }).pluck(:community_id).uniq).ids
#         when 'is_not_empty'
#           community_ids = @communities.where(id: Case.joins(:community).where.not(cases: { case_type: 'EC', exited: true }).pluck(:community_id).uniq).ids
#         end
#         community_ids
#       end

#       def get_community_member_gender
#         communities = @communities.joins(:community_members).distinct
#         case @operator
#         when 'equal'
#           communities = communities.where('community_members.gender = ?', @value)
#         when 'not_equal'
#           communities = communities.where('community_members.gender != ?', @value)
#         when 'is_empty'
#           communities = Community.includes(:community_members).where('community_members.gender IS NULL')
#         when 'is_not_empty'
#           communities = communities.where('community_members.gender IS NOT NULL')
#         end
#         communities.ids
#       end

#       def get_community_member_dob
#         communities = @communities.joins(:community_members).distinct
#         case @operator
#         when 'equal'
#           communities = communities.where('date(community_members.date_of_birth) = ?', @value.to_date)
#         when 'not_equal'
#           communities = communities.where("date(community_members.date_of_birth) != ? OR community_members.date_of_birth IS NULL", @value.to_date)
#         when 'less'
#           communities = communities.where('date(community_members.date_of_birth) < ?', @value.to_date)
#         when 'less_or_equal'
#           communities = communities.where('date(community_members.date_of_birth) <= ?', @value.to_date)
#         when 'greater'
#           communities = communities.where('date(community_members.date_of_birth) > ?', @value.to_date)
#         when 'greater_or_equal'
#           communities = communities.where('date(community_members.date_of_birth) >= ?', @value.to_date)
#         when 'between'
#           communities = communities.where('date(community_members.date_of_birth) BETWEEN ? AND ? ', @value[0].to_date, @value[1].to_date)
#         when 'is_empty'
#           communities = Community.includes(:community_members).where(community_members: { date_of_birth: nil })
#         when 'is_not_empty'
#           communities = communities.where.not(community_members: { date_of_birth: nil })
#         end
#         communities.ids
#       end
#     end
#   end
# end
