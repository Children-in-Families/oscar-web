class GovernmentFormFamilyPlan < ActiveRecord::Base
  has_paper_trail

  delegate :name, to: :family_plan, prefix: true, allow_nil: true

  belongs_to :government_form
  belongs_to :family_plan
end
