class CaseConferenceDomain < ActiveRecord::Base
  belongs_to :domain
  belongs_to :case_conference
end
