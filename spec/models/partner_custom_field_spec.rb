describe PartnerCustomField, 'associations' do
  it { is_expected.to belong_to(:partner) }
  it { is_expected.to belong_to(:custom_field) }
  it { is_expected.to validate_presence_of(:partner_id) }
  it { is_expected.to validate_presence_of(:custom_field_id) }
end

describe PartnerCustomField, 'scopes' do
  let!(:partner){ create(:partner) }
  let!(:cf1){ create(:custom_field, entity_type: 'Partner', form_title: 'Health Record') }
  let!(:cf2){ create(:custom_field, entity_type: 'Partner', form_title: 'Care Record') }
  let!(:pcf1){ create(:partner_custom_field, partner: partner, custom_field: cf1) }
  let!(:pcf2){ create(:partner_custom_field, partner: partner, custom_field: cf2) }
  let!(:pcf3){ create(:partner_custom_field, partner: partner, custom_field: cf2) }

  it 'by_custom_field' do
    expect(partner.partner_custom_fields.by_custom_field(cf2)).to include(pcf2, pcf3)
    expect(partner.partner_custom_fields.by_custom_field(cf2)).not_to include(pcf1)
  end
end
