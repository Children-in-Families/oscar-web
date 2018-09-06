class CaseClosure < ActiveRecord::Base
  has_paper_trail

  has_many :government_form_case_closures, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_case_closures

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
