describe ClientRightGovernmentForm, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:client_right) }
end

describe ClientRightGovernmentForm, 'scopes' do
  let!(:record_1){ create(:client_right_government_form) }
  let!(:record_2){ create(:client_right_government_form) }

  context 'default_scope' do
    it 'order by created_at ascending' do
      expect(ClientRightGovernmentForm.all.ids).to eq([record_1.id, record_2.id])
    end
  end
end
