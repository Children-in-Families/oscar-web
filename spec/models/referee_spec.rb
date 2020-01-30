describe Referee, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
end


describe Referee, 'associations' do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:district) }
  it { is_expected.to belong_to(:commune) }
  it { is_expected.to belong_to(:village) }

  it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:calls).dependent(:restrict_with_error) }
end
