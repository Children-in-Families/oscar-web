describe QuantitativeCase, 'associations' do
  it { is_expected.to belong_to(:quantitative_type)}
  it { is_expected.to have_and_belong_to_many(:clients)}
end

describe QuantitativeCase, 'validations' do
  it { is_expected.to validate_presence_of(:value) }
  it { is_expected.to validate_uniqueness_of(:value) }
end
