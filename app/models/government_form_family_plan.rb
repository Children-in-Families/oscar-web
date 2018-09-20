class GovernmentFormFamilyPlan < ActiveRecord::Base
  has_paper_trail

  delegate :name, to: :family_plan, prefix: true, allow_nil: true
  delegate :name, to: :family_status, prefix: true, allow_nil: true

  belongs_to :government_form
  belongs_to :family_plan
  belongs_to :family_status, class_name: 'FamilyPlan', foreign_key: :family_plan_id

  default_scope { order(:created_at) }
end
