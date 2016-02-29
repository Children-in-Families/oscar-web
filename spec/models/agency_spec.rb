describe Agency, 'associations' do
  it { is_expected.to have_and_belong_to_many(:clients)}
end

describe Agency, 'validations' do
  it { is_expected.to validate_presence_of(:name)}
  it { is_expected.to validate_uniqueness_of(:name)}
end
