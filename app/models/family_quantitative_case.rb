class FamilyQuantitativeCase < ActiveRecord::Base
  belongs_to :family
  belongs_to :quantitative_case

  has_paper_trail
end
