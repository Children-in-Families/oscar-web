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

  xcontext 'default scope' do
    it 'order by created at descending' do
      expect(Changelog.first).to eq(v2)
    end
  end
end
