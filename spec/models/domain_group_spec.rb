describe DomainGroup, 'associations' do
  it { is_expected.to have_many(:domains)}
end

describe DomainGroup, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
