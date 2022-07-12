RSpec.describe CaseConferenceDomain, type: :model do
  describe CaseConferenceDomain, 'associations' do
    it { is_expected.to belong_to(:case_conference) }
    it { is_expected.to belong_to(:domain) }
    it { is_expected.to have_many(:case_conference_addressed_issues) }
    it { is_expected.to accept_nested_attributes_for(:case_conference_addressed_issues) }
  end

  describe CaseConferenceDomain, 'validations' do
    it { is_expected.to validate_presence_of(:presenting_problem) }
  end
end
