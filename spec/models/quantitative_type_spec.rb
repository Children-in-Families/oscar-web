describe QuantitativeType, 'associations' do
  it { is_expected.to have_many(:quantitative_cases)}
  it { is_expected.to have_many(:quantitative_type_permissions).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:quantitative_type_permissions) }
end

describe QuantitativeType, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end

describe QuantitativeType, 'scopes' do
  let!(:quantitative_type){ create(:quantitative_type, name: 'a') }
  let!(:other_quantitative_type){ create(:quantitative_type, name: 'b') }
  context "default scope" do
    let!(:default_order){ [quantitative_type, other_quantitative_type] }
    it 'should order by name' do
      expect(QuantitativeType.all).to eq(default_order)
    end
  end
end
