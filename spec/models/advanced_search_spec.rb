describe AdvancedSearch, 'associations' do
  it { is_expected.to belong_to(:user) }
end

describe AdvancedSearch, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:user_id) }
end
