class CaseConferenceUser < ApplicationRecord
  belongs_to :user
  belongs_to :case_conference
end
