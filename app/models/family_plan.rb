class FamilyPlan < ActiveRecord::Base
  has_paper_trail

  has_many :government_form_family_plans, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_family_plans

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:created_at) }
end
