describe Province, 'associations'do
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:families) }
  it { is_expected.to have_many(:partner)}
  it { is_expected.to have_many(:clients)}
  it { is_expected.to have_many(:cases)}
end

describe Province, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
