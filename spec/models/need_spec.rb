describe Need, 'associations' do
  it { is_expected.to have_many(:client_needs).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:clients).through(:client_needs) }
end

describe Need, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
