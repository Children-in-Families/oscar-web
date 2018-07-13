class Plan < ActiveRecord::Base
  has_paper_trail

  has_many :government_form_plans, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_plans

  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :plan_type }
end
