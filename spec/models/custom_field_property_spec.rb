describe CustomFieldProperty, 'association' do
  it { is_expected.to belong_to(:custom_formable) }
  it { is_expected.to belong_to(:custom_field) }
  it { is_expected.to belong_to(:user) }
end

describe CustomFieldProperty, 'validations' do
  let(:custom_field_property){ build(:custom_field_property) }
  let(:required_field){ create(:custom_field, fields: [{'name'=>'date-1491790765805', 'type'=>'date', 'label'=>'Date Field', 'required'=>true, 'className'=>'calendar'}]) }
  let(:email_field){ create(:custom_field, fields: [{'name'=>'email-1491790765805', 'type'=>'text', 'subtype' => 'email', 'label'=>'Email Field', 'className'=>'form-control'}]) }
  let(:number_field){ create(:custom_field, fields: [{"max"=>"10", "min"=>"1", "name"=>"number-1496743513339", "type"=>"number", "label"=>"Spec Number Validator", "className"=>"form-control"}]) }
  let(:required_form){ build(:custom_field_property, custom_field: required_field) }
  let(:number_form){ build(:custom_field_property, custom_field: number_field) }
  let(:email_form){ build(:custom_field_property, custom_field: email_field) }
  context 'presence of custom_field' do
    it { expect(custom_field_property.valid?).to be_truthy }
  end

  context 'presence of fields' do
    it 'is valid' do
      required_form.properties = {"Date Field"=>"2017-06-06"}
      expect(required_form.valid?).to be_truthy
    end

    it 'is invalid' do
      required_form.properties = {"Date Field"=>""}
      expect(required_form.valid?).to be_falsey
    end
  end

  context 'numerical validation' do
    it 'is valid' do
      number_form.properties = {"Spec Number Validator"=>"2"}
      expect(number_form.valid?).to be_truthy
    end
    it 'is invalid' do
      number_form.properties = {"Spec Number Validator"=>"0"}
      expect(number_form.valid?).to be_falsey
    end
  end

  context 'email validation' do
    it 'is valid' do
      email_form.properties = {"Email Field"=>"test@example.com"}
      expect(email_form.valid?).to be_truthy
    end
    it 'is invalid' do
      email_form.properties = {"Email Field"=>"test"}
      expect(email_form.valid?).to be_falsey

      email_form.properties = {"Email Field"=>"test@"}
      expect(email_form.valid?).to be_falsey

      email_form.properties = {"Email Field"=>"test@example"}
      expect(email_form.valid?).to be_falsey
    end
  end
end

describe CustomFieldProperty, 'callbacks' do
  before do
    ClientHistory.destroy_all
  end
  context 'after_save' do
    context 'create_client_history if client form' do
      let!(:custom_field){ create(:custom_field, entity_type: 'Client') }
      let!(:client){ create(:client) }
      let!(:client_form) { create(:custom_field_property, custom_formable: client, custom_field: custom_field) }
      it { expect(ClientHistory.where('object.custom_field_property_ids' => client_form.id).count).to eq(1) }
      it { expect(ClientHistory.where('object.custom_field_property_ids' => client_form.id).first.client_custom_field_property_histories.count).to eq(1) }
    end
  end
end

describe CustomFieldProperty, 'scopes' do
  let!(:custom_field){ create(:custom_field) }
  let!(:first_custom_field_property){ create(:custom_field_property, custom_field: custom_field) }
  let!(:second_custom_field_property){ create(:custom_field_property, custom_field: custom_field) }

  context 'most_recents' do
    it 'order by created_at descending' do
      expect(CustomFieldProperty.all).to include(second_custom_field_property, first_custom_field_property)
    end
  end

  context 'by_custom_field' do
    it 'returns which associated with given custom_field' do
      expect(CustomFieldProperty.by_custom_field(custom_field)).to include(first_custom_field_property, second_custom_field_property)
    end
  end
end

# describe CustomFieldProperty, 'instance methods' do
#   let!(:client_custom_field){ create(:custom_field, entity_type: 'Client') }
#   let!(:family_custom_field){ create(:custom_field, entity_type: 'Family') }
#   let!(:client){ create(:client) }
#   let!(:family){ create(:family) }
#   let!(:client_custom_field_property){ create(:custom_field_property, custom_field: client_custom_field, custom_formable: client) }
#   let!(:family_custom_field_property){ create(:custom_field_property, custom_field: family_custom_field, custom_formable: family) }
#
#   context 'client_form?' do
#     it 'returns true if client form' do
#       expect(client_custom_field_property.client_form?).to be_truthy
#     end
#
#     it 'returns false if family form' do
#       expect(family_custom_field_property.client_form?).to be_falsey
#     end
#   end
# end
