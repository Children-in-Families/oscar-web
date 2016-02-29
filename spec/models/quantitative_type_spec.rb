describe QuantitativeType, 'associations' do
  it { is_expected.to have_many(:quantitative_cases)}
end

describe QuantitativeType, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
