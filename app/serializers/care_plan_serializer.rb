class CarePlanSerializer < ActiveModel::Serializer
  attributes :id, :assessment_id, :client_id, :family_id, :completed, :care_plan_date

  has_many :goals
  has_many :assessment_domains
end
