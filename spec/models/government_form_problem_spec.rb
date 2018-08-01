describe GovernmentFormProblem, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:problem) }
end

describe GovernmentFormProblem, 'CONSTANTS' do
  context 'RANKS' do
    it 'returns the rank from 1 to 16' do
      expect(GovernmentFormProblem::RANKS).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
    end
  end
end

describe GovernmentFormProblem, 'scopes' do
  let!(:record_1){ create(:government_form_problem) }
  let!(:record_2){ create(:government_form_problem) }

  context 'default_scope' do
    it 'order by created_at ascending' do
      expect(GovernmentFormProblem.all.ids).to eq([record_1.id, record_2.id])
    end
  end
end
