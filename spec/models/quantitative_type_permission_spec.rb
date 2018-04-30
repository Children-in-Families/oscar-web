describe QuantitativeTypePermission, 'associations' do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:quantitative_type) }
end

describe QuantitativeTypePermission, 'scopes' do
  let!(:user) { create(:user, :admin) }
  let!(:quantitative_type) { create(:quantitative_type, name: 'DEF') }
  let!(:quantitative_type_permission) { create(:quantitative_type_permission, user: user, quantitative_type: quantitative_type) }

  let!(:second_quantitative_type) { create(:quantitative_type, name: 'ABC') }
  let!(:second_quantitative_type_permission) { create(:quantitative_type_permission, user: user, quantitative_type: second_quantitative_type, readable: false, editable: false) }

  context 'order by quantitative type' do
    it 'should return second quantitative type first' do
      expect(QuantitativeTypePermission.order_by_quantitative_type.first.id).to eq(second_quantitative_type_permission.id)
    end
  end

  context 'quantitative type permission readable' do
    it 'should return quantitative type permission' do
      expect(QuantitativeTypePermission.readable).to include(quantitative_type_permission)
      expect(QuantitativeTypePermission.readable).not_to include(second_quantitative_type_permission)
    end
  end

  context 'quantitative type permission editable' do
    it 'should return second quantitative type permission' do
      expect(QuantitativeTypePermission.editable).to include(quantitative_type_permission)
      expect(QuantitativeTypePermission.editable).not_to include(second_quantitative_type_permission)
    end
  end
end
