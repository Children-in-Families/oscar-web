describe Visit, 'associations' do
  it { is_expected.to belong_to(:user)}
end

describe Visit, 'scopes' do
  let!(:user){ create(:user) }
  let!(:dev){ create(:user, email: ENV['DEV_EMAIL']) }
  let!(:visit) { create(:visit, user: user, created_at: 1.month.ago) }
  let!(:other_visit) { create(:visit, user: dev, created_at: 2.months.ago, ) }

  context 'excludes_non_devs' do
    it 'should not include records of non_devs' do
      expect(Visit.excludes_non_devs).to include(visit)
      expect(Visit.excludes_non_devs).not_to include(other_visit)
    end
  end

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
