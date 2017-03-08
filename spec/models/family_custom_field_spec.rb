describe FamilyCustomField, 'associations' do
  it { is_expected.to belong_to(:family) }
  it { is_expected.to belong_to(:custom_field) }
  it { is_expected.to validate_presence_of(:family_id) }
  it { is_expected.to validate_presence_of(:custom_field_id) }
end

describe FamilyCustomField, 'scopes' do
  let!(:family){ create(:family) }
  let!(:cf1){ create(:custom_field, entity_type: 'Family', form_title: 'Health Record') }
  let!(:cf2){ create(:custom_field, entity_type: 'Family', form_title: 'Care Record') }
  let!(:fcf1){ create(:family_custom_field, family: family, custom_field: cf1) }
  let!(:fcf2){ create(:family_custom_field, family: family, custom_field: cf2) }
  let!(:fcf3){ create(:family_custom_field, family: family, custom_field: cf2) }

  it 'by_custom_field' do
    expect(family.family_custom_fields.by_custom_field(cf2)).to include(fcf2, fcf3)
    expect(family.family_custom_fields.by_custom_field(cf2)).not_to include(fcf1)
  end
end
