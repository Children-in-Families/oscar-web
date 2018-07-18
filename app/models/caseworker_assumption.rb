class CaseworkerAssumption < ActiveRecord::Base
  has_paper_trail

  has_many  :caseworker_assumption_government_forms, dependent: :restrict_with_error
  has_many  :government_forms, through: :caseworker_assumption_government_forms

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
