describe Province, 'associations'do
  it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:families).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:partners).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:cases).dependent(:restrict_with_error) }
end

describe Province, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
