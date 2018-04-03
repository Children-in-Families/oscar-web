describe CustomFieldPermission, 'associations' do
  it { is_expected.to belong_to(:user_permission) }
  it { is_expected.to belong_to(:user_custom_field_permission) }
end

describe CustomFieldPermission, 'scopes' do
  let!(:user) { create(:user, :admin) }
  let!(:first_custom_field) { create(:custom_field, form_title: 'DEF') }
  let!(:first_custom_field_permission) { create(:custom_field_permission, user_id: user.id, custom_field_id: first_custom_field.id) }

  let!(:second_custom_field) { create(:custom_field, form_title: 'ABC') }
  let!(:second_custom_field_permission) { create(:custom_field_permission, user_id: user.id, custom_field_id: second_custom_field.id) }

  context 'order by form title' do
    it 'should return second custom field first' do
      expect(CustomFieldPermission.order_by_form_title.first.custom_field_id).to eq(second_custom_field.id) 
    end
  end
end