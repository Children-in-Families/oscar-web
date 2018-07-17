class GovernmentFormChildrenPlan < ActiveRecord::Base
  has_paper_trail

  delegate :name, to: :children_plan, prefix: true, allow_nil: true

  belongs_to :government_form
  belongs_to :children_plan
end
