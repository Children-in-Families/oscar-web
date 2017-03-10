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

# describe ClientCustomField, 'validation' do
#   client       = Client.create()
#   custom_field = CustomField.create(fields: ['required':true].to_json)
#   ccf          = ClientCustomField.new(client: client, custom_field: custom_field , properties: ['name':''].to_json)
#   it { expect(ccf).to be_invalid }
# end
