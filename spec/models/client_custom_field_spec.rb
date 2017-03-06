describe ClientCustomField, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:custom_field) }
  it { is_expected.to validate_presence_of(:client_id) }
  it { is_expected.to validate_presence_of(:custom_field_id) }
end

describe ClientCustomField, 'scopes' do
  let!(:client){ create(:client) }
  let!(:cf1){ create(:custom_field, entity_type: 'Client', form_title: 'Health Record') }
  let!(:cf2){ create(:custom_field, entity_type: 'Client', form_title: 'Care Record') }
  let!(:ccf1){ create(:client_custom_field, client: client, custom_field: cf1) }
  let!(:ccf2){ create(:client_custom_field, client: client, custom_field: cf2) }
  let!(:ccf3){ create(:client_custom_field, client: client, custom_field: cf2) }

  it 'by_custom_field' do
    expect(client.client_custom_fields.by_custom_field(cf2)).to include(ccf2, ccf3)
    expect(client.client_custom_fields.by_custom_field(cf2)).not_to include(ccf1)
  end
end

describe ClientCustomField, 'methods' do
  context 'can_create_next_custom_field?' do
    let!(:client){ create(:client) }
    let!(:custom_field){ create(:custom_field, entity_type: 'Client', form_title: 'Health Record', frequency: 'Day', time_of_frequency: 1) }
    let!(:client_custom_field){ create(:client_custom_field, custom_field: custom_field, client: client) }
    let!(:other_custom_field){ create(:custom_field, entity_type: 'Client', form_title: 'Care Record', frequency: '') }
    let!(:other_client_custom_field){ create(:client_custom_field, custom_field: other_custom_field, client: client) }

    it { expect(client.can_create_next_custom_field?(custom_field)).to be_falsey }
    it { expect(client.can_create_next_custom_field?(other_custom_field)).to be_truthy }
  end
end
