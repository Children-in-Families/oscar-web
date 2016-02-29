describe User, 'associations' do
  it { is_expected.to belong_to(:province)}
  it { is_expected.to belong_to(:department)}
  it { is_expected.to have_many(:cases)}
  it { is_expected.to have_many(:clients)}
end

describe User, 'validations' do
  it { is_expected.to validate_presence_of(:roles) }
end
