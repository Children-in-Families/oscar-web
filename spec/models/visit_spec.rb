describe Visit, 'associations' do
  it { is_expected.to belong_to(:user)}
end

describe Visit, 'scopes' do
  let!(:user){ create(:user) }
  let!(:dev){ create(:user, email: ENV['DEV_EMAIL']) }
  let!(:visit) { create(:visit, user: user, created_at: 1.month.ago) }
  let!(:other_visit) { create(:visit, user: dev, created_at: 2.months.ago, ) }

  context '.excludes_non_devs' do
    it 'should not include records of non_devs' do
      expect(Visit.excludes_non_devs).to include(visit)
      expect(Visit.excludes_non_devs).not_to include(other_visit)
    end
  end

  context '.total_logins(from, to)' do
    beginning_of_month = 1.month.ago.beginning_of_month
    end_of_month       = 1.month.ago.end_of_month
    subject{ Visit.total_logins(beginning_of_month, end_of_month) }
    it 'include visit in this month' do
      is_expected.to include(visit)
    end
    it 'not include visit in this month' do
      is_expected.not_to include(other_visit)
    end
  end
end
