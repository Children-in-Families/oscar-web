class CaseConferenceAddressedIssue < ApplicationRecord
  belongs_to :case_conference_domain

  validates :title, presence: true
end
