describe ChangelogType, 'associations' do
  it { is_expected.to belong_to(:changelog) }
end

describe ChangelogType, 'validations' do
  it { is_expected.to validate_presence_of(:change_type) }
  it { is_expected.to validate_presence_of(:description) }

  it 'should validate uniqueness of description scoped to changelog_id and change_type' do
    FactoryBot.create(:changelog_type)
    should validate_uniqueness_of(:description).scoped_to([:changelog_id, :change_type])
  end
end
