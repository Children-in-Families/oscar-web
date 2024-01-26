class GoalSerializer < ActiveModel::Serializer
  attributes :id, :description, :assessment_domain_id, :domain_id, :client_id, :assessment_id, :care_plan_id, :family_id

  has_many :tasks
end
