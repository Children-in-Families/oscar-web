class AssessmentTask < ActiveRecord::Base
  belongs_to :kinship_or_foster_care_case
  belongs_to :domain

  validates  :kinship_or_foster_care_case_id, presence: true
  validates  :domain_id, presence: true
end
