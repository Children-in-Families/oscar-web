class Problem < ActiveRecord::Base
  has_paper_trail

  has_many :government_form_problems, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_problems

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
