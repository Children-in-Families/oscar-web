describe GovernmentFormServiceType, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:service_type) }
end

describe GovernmentFormServiceType, 'scopes' do
  let!(:record_1){ create(:government_form_service_type) }
  let!(:record_2){ create(:government_form_service_type) }

  context 'default_scope' do
    it 'order by created_at ascending' do
      expect(GovernmentFormServiceType.all.ids).to eq([record_1.id, record_2.id])
    end
  end
end
