describe QuantitativeCase, 'associations' do
  it { is_expected.to belong_to(:quantitative_type)}
  it { is_expected.to have_and_belong_to_many(:clients)}
end

describe QuantitativeCase, 'validations' do
  it { is_expected.to validate_presence_of(:value) }
  it { is_expected.to validate_uniqueness_of(:value) }
end

describe QuantitativeCase, 'scopes' do
  let!(:quantitative_type){ create(:quantitative_type, name: 'Example') }
  let!(:quantitative_case){ create(:quantitative_case, value: 'a') }
  let!(:other_quantitative_case){ create(:quantitative_case, value: 'b', quantitative_type: quantitative_type) }

  context 'default scope' do
    let!(:default_order){ [quantitative_case, other_quantitative_case] }
    it 'should order by value' do
      expect(QuantitativeCase.all).to eq(default_order)
    end
  end
end
