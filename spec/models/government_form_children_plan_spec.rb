describe GovernmentFormChildrenPlan, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:children_plan) }
  it { is_expected.to belong_to(:children_status).class_name('ChildrenPlan').with_foreign_key(:children_plan_id) }
end

describe GovernmentFormChildrenPlan, 'scopes' do
  let!(:record_1){ create(:government_form_children_plan) }
  let!(:record_2){ create(:government_form_children_plan) }

  context 'default_scope' do
    it 'order by created_at ascending' do
      expect(GovernmentFormChildrenPlan.all.ids).to eq([record_1.id, record_2.id])
    end
  end
end
