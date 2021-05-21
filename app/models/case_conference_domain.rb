class CaseConferenceDomain < ActiveRecord::Base
  belongs_to :domain
  belongs_to :case_conference

  validates :presenting_problem, presence: true
end
