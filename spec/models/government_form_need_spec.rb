describe GovernmentFormNeed, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:need) }
end

describe GovernmentFormNeed, 'CONSTANTS' do
  context 'RANKS' do
    it 'returns the rank from 1 to 8' do
      expect(GovernmentFormNeed::RANKS).to eq([1, 2, 3, 4, 5, 6, 7, 8])
    end
  end
end

describe GovernmentFormNeed, 'scopes' do
  let!(:record_1){ create(:government_form_need) }
  let!(:record_2){ create(:government_form_need) }

  context 'default_scope' do
    it 'order by created_at ascending' do
      expect(GovernmentFormNeed.all.ids).to eq([record_1.id, record_2.id])
    end
  end
end
