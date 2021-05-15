RSpec.describe CaseConference, type: :model do
  describe CaseConference, 'associations' do
    it { is_expected.to belong_to(:client) }
    it { is_expected.to have_one(:assessment) }
    it { is_expected.to have_many(:case_conference_domains).dependent(:destroy) }
    it { is_expected.to have_many(:domains).through(:case_conference_domains) }
    it { is_expected.to have_many(:case_conference_users).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:case_conference_users) }
  end

  describe CaseConference, 'validations' do
    it { is_expected.to validate_presence_of(:meeting_date) }
    it { is_expected.to validate_presence_of(:user_ids) }
  end
end
