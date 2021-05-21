class CaseConferenceUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :case_conference
end
