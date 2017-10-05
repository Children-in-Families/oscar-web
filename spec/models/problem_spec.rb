describe Problem, 'associations' do
  it { is_expected.to have_many(:client_problems).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:clients).through(:client_problems) }
end

describe Problem, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
