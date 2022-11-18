class CommunityQuantitativeCaseBase < ApplicationRecord
  self.table_name = 'community_quantitative_cases'

  belongs_to :community
  has_paper_trail
end
