describe GovernmentFormFamilyPlan, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:family_plan) }
  it { is_expected.to belong_to(:family_status).class_name('FamilyPlan').with_foreign_key(:family_plan_id) }
end

describe GovernmentFormFamilyPlan, 'scopes' do
  let!(:record_1){ create(:government_form_family_plan) }
  let!(:record_2){ create(:government_form_family_plan) }

  context 'default_scope' do
    it 'order by created_at ascending' do
      expect(GovernmentFormFamilyPlan.all.ids).to eq([record_1.id, record_2.id])
    end
  end
end
