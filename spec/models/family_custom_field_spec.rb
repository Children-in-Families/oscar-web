describe FamilyCustomField, 'associations' do
  it { is_expected.to belong_to(:family) }
  it { is_expected.to belong_to(:custom_field) }
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

describe FamilyCustomField, 'methods' do
  context 'can_create_next_custom_field?' do
    let!(:family){ create(:family) }
    let!(:custom_field){ create(:custom_field, entity_type: 'Family', form_title: 'Health Record', frequency: 'Daily', time_of_frequency: 1) }
    let!(:family_custom_field){ create(:family_custom_field, custom_field: custom_field, family: family) }
    let!(:other_custom_field){ create(:custom_field, entity_type: 'Family', form_title: 'Care Record', frequency: '') }
    let!(:other_family_custom_field){ create(:family_custom_field, custom_field: other_custom_field, family: family) }

    it { expect(family.can_create_next_custom_field?(family, custom_field)).to be_falsey }
    it { expect(family.can_create_next_custom_field?(family, other_custom_field)).to be_truthy }
  end
end
