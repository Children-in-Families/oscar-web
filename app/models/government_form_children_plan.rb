class GovernmentFormChildrenPlan < ActiveRecord::Base
  has_paper_trail

  delegate :name, to: :children_plan, prefix: true, allow_nil: true
  delegate :name, to: :children_status, prefix: true, allow_nil: true

  belongs_to :government_form
  belongs_to :children_plan
  belongs_to :children_status, class_name: 'ChildrenPlan', foreign_key: :children_plan_id

  default_scope { order(:created_at) }
end
