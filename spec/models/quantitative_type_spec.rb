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

describe QuantitativeType, 'callbacks' do
  describe 'after_create' do
    context '#build_permission' do
      let!(:quantitative_type) { create(:quantitative_type) }
      let!(:user) { create(:user) }

      it 'create records in quantitative type permission' do
        expect(user.quantitative_type_permissions.first.user_id).to eq(user.id)
        expect(user.quantitative_type_permissions.first.quantitative_type_id).to eq(quantitative_type.id)
        expect(user.quantitative_type_permissions.first.readable).to eq(true)
        expect(user.quantitative_type_permissions.first.editable).to eq(true)
      end
    end
  end
end
