describe GovernmentFormFamilyPlan, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:family_plan) }
  it { is_expected.to belong_to(:family_status).class_name('FamilyPlan').with_foreign_key(:family_plan_id) }
end
