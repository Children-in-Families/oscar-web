class Need < ActiveRecord::Base
  has_paper_trail

  has_many :government_form_needs, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_needs

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
