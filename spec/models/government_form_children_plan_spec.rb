describe GovernmentFormChildrenPlan, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:children_plan) }
  it { is_expected.to belong_to(:children_status).class_name('ChildrenPlan').with_foreign_key(:children_plan_id) }
end
