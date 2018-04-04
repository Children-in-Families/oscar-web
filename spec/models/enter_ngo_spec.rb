describe ExitNgo, 'associations' do
  it { is_expected.to belong_to(:client) }
end

describe Agency, 'validations' do
  it { is_expected.to validate_presence_of(:accepted_date)}
end
