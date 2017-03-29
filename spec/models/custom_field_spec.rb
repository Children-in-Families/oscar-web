describe CustomField, 'associations' do
  it { is_expected.to have_many(:clients).through(:client_custom_fields) }
  it { is_expected.to have_many(:client_custom_fields).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:families).through(:family_custom_fields) }
  it { is_expected.to have_many(:family_custom_fields).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:partners).through(:partner_custom_fields) }
  it { is_expected.to have_many(:partner_custom_fields).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:user).through(:user_custom_fields) }
  it { is_expected.to have_many(:user_custom_fields).dependent(:restrict_with_error) }
end

describe CustomField, 'validations' do
  it { is_expected.to validate_presence_of(:entity_type) }
  it { is_expected.to validate_presence_of(:form_title) }
  it { is_expected.to validate_uniqueness_of(:form_title).case_insensitive.scoped_to(:entity_type) }
  it 'validates presence of fields' do
    custom_field = CustomField.new
    custom_field.save
    expect(custom_field.errors[:fields]).to include("can't be blank")
  end
  it 'validates time of frequency value if frequency' do
    custom_field = CustomField.new(frequency: 'Day')
    custom_field.save
    expect(custom_field.errors[:time_of_frequency]).to include('must be greater than or equal to 1')
  end
  it 'validates time of frequency value data type if frequency' do
    custom_field = CustomField.new(frequency: 'Day', time_of_frequency: 1.1)
    custom_field.save
    expect(custom_field.errors[:time_of_frequency]).to include('must be an integer')
  end
end

describe CustomField, 'scopes' do
  context 'find custom fields by form title' do
    let!(:custom_field) { create(:custom_field, form_title: 'Health Record') }
    let!(:other_custom_field) { create(:custom_field, form_title: 'Prosin Record') }

    subject{ CustomField.by_form_title('health record') }

    it 'should include custom field like the form title' do
      is_expected.to include(custom_field)
    end
    it 'should not include custom field like the form title' do
      is_expected.not_to include(other_custom_field)
    end
  end
end

describe CustomField, 'CONSTANTS' do
  it 'FREQUENCIES' do
    expect(CustomField::FREQUENCIES).to eq(['Daily', 'Weekly', 'Monthly', 'Yearly'])
  end
  it 'ENTITY_TYPES' do
    expect(CustomField::ENTITY_TYPES).to eq(['Client', 'Family', 'Partner', 'User'])
  end
end

describe CustomField, 'callbacks' do
  let!(:frequency_custom_field){ create(:custom_field, frequency: 'Day', time_of_frequency: 12) }
  let!(:no_frequency_custom_field){ create(:custom_field, frequency: '', form_title: 'Health Care') }
  context 'set_time_of_frequency' do
    it 'any frequency is chosen then it should have time of frequency' do
      expect(frequency_custom_field.time_of_frequency).to eq(12)
    end
    it 'no frequency is chosen then it should not have time of frequency' do
      expect(no_frequency_custom_field.time_of_frequency).to eq(0)
    end
  end
end
