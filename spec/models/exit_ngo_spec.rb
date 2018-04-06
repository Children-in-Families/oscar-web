describe ExitNgo, 'associations' do
  it { is_expected.to belong_to(:client) }
end

describe ExitNgo, 'validations' do
  it { is_expected.to validate_presence_of(:exit_circumstance)}
  it { is_expected.to validate_presence_of(:exit_note)}
  it { is_expected.to validate_presence_of(:exit_date)}
end
