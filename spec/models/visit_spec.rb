describe Visit, 'associations' do
  it { is_expected.to belong_to(:user)}
end

describe Visit, 'scopes' do
  let!(:user){ create(:user) }
  let!(:visit) { create(:visit, user: user) }
  let!(:other_visit) { create(:visit, user: user, created_at: 2.months.ago) }

  context 'find user login per month' do
    subject{ Visit.previous_month_logins }
    it 'should include visit in this month' do
      is_expected.to include(visit)
    end
    it 'should not include visit in this month' do
      is_expected.not_to include(other_visit)
    end
  end
end
