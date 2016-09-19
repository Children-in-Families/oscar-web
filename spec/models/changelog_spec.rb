describe Changelog, 'associations' do
  it { is_expected.to belong_to(:user)}
end

describe Changelog, 'validations' do
  it { is_expected.to validate_presence_of(:user_id)}
  it { is_expected.to validate_presence_of(:version)}
  it { is_expected.to validate_presence_of(:description)}
  it { is_expected.to validate_uniqueness_of(:version)}
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
