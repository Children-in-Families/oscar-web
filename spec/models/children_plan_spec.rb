describe ChildrenPlan, 'associations' do
  it { is_expected.to have_many(:government_form_children_plans).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:government_forms).through(:government_form_children_plans) }
end

describe ChildrenPlan, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end

describe ChildrenPlan, 'scopes' do
  let!(:record_1){ create(:children_plan) }
  let!(:record_2){ create(:children_plan) }

  context 'default_scope' do
    it 'order by created_at ascending' do
      expect(ChildrenPlan.all.ids).to eq([record_1.id, record_2.id])
    end
  end
end
