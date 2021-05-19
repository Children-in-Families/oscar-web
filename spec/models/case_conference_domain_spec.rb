RSpec.describe CaseConferenceDomain, type: :model do
  describe CaseConferenceDomain, 'associations' do
    it { is_expected.to belong_to(:case_conference) }
    it { is_expected.to belong_to(:domain) }
  end

  describe CaseConferenceDomain, 'validations' do
    it { is_expected.to validate_presence_of(:presenting_problem) }
  end
end
