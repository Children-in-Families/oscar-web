require 'rails_helper'

RSpec.describe CaseConferenceAddressedIssue, type: :model do

  describe CaseConferenceAddressedIssue, 'associations' do
    it { is_expected.to belong_to(:case_conference_domain) }
  end

  describe CaseConferenceAddressedIssue, 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end
end
