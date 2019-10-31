describe Caller, 'associations' do
  it { is_expected.to have_many(:calls).dependent(:restrict_with_error) }
end

describe Caller, 'validations' do
  it { is_expected.to validate_presence_of(:answered_call) }
end
