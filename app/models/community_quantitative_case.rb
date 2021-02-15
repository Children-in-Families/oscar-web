class CommunityQuantitativeCase < ActiveRecord::Base
  belongs_to :community
  belongs_to :quantitative_case

  has_paper_trail
end
