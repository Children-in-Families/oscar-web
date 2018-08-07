class FollowUpRecord < ActiveRecord::Base
  belongs_to :government_form

  has_paper_trail
end
