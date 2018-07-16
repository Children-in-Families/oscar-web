class Interviewee < ActiveRecord::Base
  has_paper_trail

  has_many :government_form_interviewees, dependent: :restrict_with_error
  has_many :government_forms, through: :government_form_interviewees

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
