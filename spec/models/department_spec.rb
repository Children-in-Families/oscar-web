describe Department, 'associations' do
  it { is_expected.to have_many(:users)}
end

describe Department, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
