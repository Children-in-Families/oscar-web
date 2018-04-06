describe EnterNgo, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to have_many(:enter_ngo_users).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:enter_ngo_users) }
end

describe EnterNgo, 'validations' do
  it { is_expected.to validate_presence_of(:accepted_date)}
end
