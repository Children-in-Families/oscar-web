describe GovernmentForm, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:district) }
  it { is_expected.to belong_to(:commune) }
  it { is_expected.to belong_to(:village) }
  it { is_expected.to belong_to(:interview_province).class_name('Province').with_foreign_key('interview_province_id') }
  it { is_expected.to belong_to(:interview_district).class_name('District').with_foreign_key('interview_district_id') }
  it { is_expected.to belong_to(:interview_commune).class_name('Commune').with_foreign_key('interview_commune_id') }
  it { is_expected.to belong_to(:interview_village).class_name('Village').with_foreign_key('interview_village_id') }
  it { is_expected.to belong_to(:assessment_province).class_name('Province').with_foreign_key('assessment_province_id') }
  it { is_expected.to belong_to(:assessment_district).class_name('District').with_foreign_key('assessment_district_id') }
  it { is_expected.to belong_to(:assessment_commune).class_name('Commune').with_foreign_key('assessment_commune_id') }
  it { is_expected.to belong_to(:primary_carer_province).class_name('Province').with_foreign_key('primary_carer_province_id') }
  it { is_expected.to belong_to(:primary_carer_district).class_name('District').with_foreign_key('primary_carer_district_id') }
  it { is_expected.to belong_to(:primary_carer_commune).class_name('Commune').with_foreign_key('primary_carer_commune_id') }
  it { is_expected.to belong_to(:primary_carer_village).class_name('Village').with_foreign_key('primary_carer_village_id') }

  it { is_expected.to have_many(:government_form_interviewees).dependent(:destroy) }
  it { is_expected.to have_many(:interviewees).through(:government_form_interviewees) }
  it { is_expected.to have_many(:client_type_government_forms).dependent(:destroy) }
  it { is_expected.to have_many(:client_types).through(:client_type_government_forms) }
  it { is_expected.to have_many(:government_form_needs).dependent(:destroy) }
  it { is_expected.to have_many(:needs).through(:government_form_needs) }
  it { is_expected.to have_many(:government_form_problems).dependent(:destroy) }
  it { is_expected.to have_many(:problems).through(:government_form_problems) }

  it { is_expected.to have_many(:government_form_children_plans).dependent(:destroy) }
  it { is_expected.to have_many(:children_plans).through(:government_form_children_plans) }
  it { is_expected.to have_many(:children_statuses).class_name('ChildrenPlan').through(:government_form_children_plans) }

  it { is_expected.to have_many(:government_form_family_plans).dependent(:destroy) }
  it { is_expected.to have_many(:family_plans).through(:government_form_family_plans) }
  it { is_expected.to have_many(:family_statuses).class_name('FamilyPlan').through(:government_form_family_plans) }

  it { is_expected.to have_many(:government_form_service_types).dependent(:destroy) }
  it { is_expected.to have_many(:service_types).through(:government_form_service_types) }

  it { is_expected.to have_many(:client_right_government_forms).dependent(:destroy) }
  it { is_expected.to have_many(:client_rights).through(:client_right_government_forms) }
end

describe GovernmentForm, 'callbacks' do
  let!(:village_1){ create(:village, code: '123456') }
  let!(:form_1){ create(:government_form, village: village_1, client_code: '01') }

  context 'before_save' do
    context '#concat_client_code_with_village_code' do
      it 'form a client code' do
        expect(form_1.client_code).to eq('12345601')
      end
    end
  end
end

describe GovernmentForm, 'methods' do
  let!(:user_1){ create(:user) }
  let!(:form_1){ create(:government_form) }
  let!(:form_2){ create(:government_form, name: 'ABC', case_worker_id: user_1.id) }
  context '#populate_needs' do
    it 'builds government form needs' do
      expect(form_1.populate_needs.count).to eq(Need.count)
    end
  end

  context '#populate_problems' do
    it 'builds government form problems' do
      expect(form_1.populate_problems.count).to eq(Problem.count)
    end
  end

  context '#populate_children_plans' do
    it 'builds government form children plans' do
      expect(form_1.populate_children_plans.count).to eq(ChildrenPlan.where.not(name: 'តម្រូវការជំនួយផ្នែកច្បាប់').count)
    end
  end

  context '#populate_family_plans' do
    it 'builds government form family plans' do
      expect(form_1.populate_family_plans.count).to eq(FamilyPlan.where.not(name: 'កម្រិតសិក្សាអប់រំ').count)
    end
  end

  context '#populate_children_status' do
    it 'builds government form children status' do
      expect(form_1.populate_children_status.count).to eq(ChildrenPlan.count)
    end
  end

  context '#populate_family_status' do
    it 'builds government form family status' do
      expect(form_1.populate_family_status.count).to eq(ChildrenPlan.where.not(name: 'ចំណេះដឹងទូទៅក្នុងសង្គម').count)
    end
  end

  context '.filter(options)' do
    it 'filtered by passing options' do
      expect(GovernmentForm.filter({name: 'ABC'}).ids).to include(form_2.id)
      expect(GovernmentForm.filter({name: 'ABC'}).ids).not_to include(form_1.id)
    end
  end

  context '#case_worker_info' do
    it 'returns a selected case worker' do
      expect(form_2.case_worker_info).to eq(user_1)
    end
  end
end
