describe Changelog, 'associations' do
  it { is_expected.to belong_to(:user)}
  it { is_expected.to have_many(:changelog_types).dependent(:destroy) }
end

describe Changelog, 'validations' do
  it { is_expected.to validate_presence_of(:user_id)}
  it { is_expected.to validate_presence_of(:change_version)}
  it { is_expected.to validate_uniqueness_of(:change_version)}
end

describe Changelog, 'scope' do
  let!(:v1) { create(:changelog) }
  let!(:v2) { create(:changelog) }

  context 'default scope' do
    it 'order by created at descending' do
      expect(Changelog.first).to eq(v2)
    end
  end
end

describe Changelog, 'callbacks' do
  context 'after create' do
    context 'notify_admins' do
      let!(:admin) { create(:user, roles: 'admin', email: 'admin@gmail.com') }
      let!(:other_admin) { create(:user, roles: 'admin', email: 'other.admin@gmail.com') }
      it 'send an alert email to admins when there is a new release' do
        FactoryGirl.create(:changelog)
        expect(ActionMailer::Base.deliveries.last.to).to include('admin@gmail.com', 'other.admin@gmail.com')
      end
    end
  end
end
