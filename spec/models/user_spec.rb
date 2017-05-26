describe User, 'associations' do
  it { is_expected.to belong_to(:province)}
  it { is_expected.to belong_to(:department)}
  it { is_expected.to have_many(:visits).dependent(:destroy) }
  it { is_expected.to have_many(:tasks).dependent(:destroy) }
  it { is_expected.to have_many(:cases).dependent(:restrict_with_error)}
  it { is_expected.to have_many(:clients).dependent(:restrict_with_error)}
  it { is_expected.to have_many(:changelogs).dependent(:restrict_with_error)}
  it { is_expected.to have_many(:progress_notes).dependent(:restrict_with_error)}
  it { is_expected.to have_many(:custom_field_properties).dependent(:destroy) }
  it { is_expected.to have_many(:custom_fields).through(:custom_field_properties) }
end

describe User, 'validations' do
  it { is_expected.to validate_presence_of(:roles) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_inclusion_of(:roles).in_array(User::ROLES)}
end

describe User, 'callbacks' do
  context 'assign as admin' do
    let!(:user){ create(:user, roles: 'admin', first_name: 'Coca', last_name: 'Cola') }
    before do
      user.admin = true if user.admin?
      user.reload
    end

    it 'should assign user to be admin' do
      expect(user.admin).to be_truthy
    end
  end
end

describe User, 'scopes' do
  let(:department) { create(:department) }
  let(:other_department) { create(:department) }
  let(:province) { create(:province) }

  let!(:user){ create(:user,
    first_name: 'Example First Name',
    last_name: 'Example Last Name',
    mobile: '+1234567890',
    job_title: 'Developer',
    department: department,
    roles: 'admin',
    province: province
  ) }
  let!(:other_user){ create(:user, department: department, province: province) }
  let!(:no_department_user){ create(:user, province: province) }
  let!(:user_in_other_department){ create(:user,department: other_department, province: province) }
  let!(:ec_manager){ create(:user, :ec_manager) }
  let!(:able_manager){ create(:user, :able_manager) }

  context 'first name like' do
    subject{ User.first_name_like(user.first_name.downcase) }
    it 'should include first name like' do
      is_expected.to include(user)
    end
    it 'should not include not first name like' do
      is_expected.not_to include(other_user)
    end
  end

  context 'last name like' do
    subject{ User.last_name_like(user.last_name.downcase) }
    it 'should include last name like' do
      is_expected.to include(user)
    end
    it 'should not include not last name like' do
      is_expected.not_to include(other_user)
    end
  end

  context 'mobile like' do
    subject{ User.mobile_like(user.mobile) }
    it 'should include mobile like' do
      is_expected.to include(user)
    end
    it 'should not include not mobile like' do
      is_expected.not_to include(other_user)
    end
  end

  context 'email like' do
    subject{ User.email_like(user.email) }
    it 'should include email like' do
      is_expected.to include(user)
    end
    it 'should not include not email like' do
      is_expected.not_to include(other_user)
    end
  end

  context 'in department' do
      subject{ User.in_department(department.id) }
      it 'should include user in department' do
        is_expected.to include(user)
      end
      it 'should not include user do not have department' do
        is_expected.not_to include(no_department_user)
      end
      it 'should not include user in other department' do
        is_expected.not_to include(user_in_other_department)
      end
    end

  context 'job title are' do
    subject{ User.job_title_are }

    it 'should include job title' do
      is_expected.to include('Developer')
    end
  end

  context 'department are' do
    subject{ User.department_are }

    it 'should include department' do
      department_array = [department.name, department.id]
      is_expected.to include(department_array)
    end
  end

  context 'case workers' do
    subject{ User.case_workers }

    it 'should include case worker role' do
      is_expected.to include(other_user)
    end
  end

  context 'admins' do
    subject{ User.admins }

    it 'should include admin role' do
      is_expected.to include(user)
    end
  end

  context 'able_managers' do
    subject{ User.able_managers }

    it 'should include able manager role' do
      is_expected.to include(able_manager)
    end
  end

  context 'ec_managers' do

    subject{ User.ec_managers}

    it 'should include on ec manager' do
      is_expected.to include(ec_manager)
    end

    it 'should not include admin' do
      is_expected.not_to include(user)
    end
  end

  context 'province are' do
    subject{ User.province_are }

    it 'should include province' do
      province_array = [province.name, province.id]
      is_expected.to include(province_array)
    end
  end

  context 'has clients' do
    let!(:client) { create(:client, user: other_user) }
    subject { User.has_clients }

    it 'should include user that has clients' do
      is_expected.to include(other_user)
    end
  end

  context 'non_strategic_overviewers' do
    let!(:strategic_overviewer) { create(:user, roles: 'strategic overviewer')}
    subject{ User.non_strategic_overviewers }

    it 'should not include strategic overviewer role' do
      is_expected.not_to include(strategic_overviewer)
    end
  end
end

describe User, 'methods' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:case_worker){ create(:user, roles: 'case worker', first_name: 'First Name', last_name: 'Last Name') }
  let!(:ec_manager){ create(:user, roles: 'ec manager') }
  let!(:fc_manager){ create(:user, roles: 'fc manager') }
  let!(:kc_manager){ create(:user, roles: 'kc manager') }
  let!(:able_manager){ create(:user, roles: 'able manager') }
  let!(:client) { create(:client, user: case_worker) }
  let!(:assessment) { create(:assessment, client: client, created_at: Date.today) }

  let!(:ec_case_worker){ create(:user, roles: 'case worker', first_name: FFaker::Name.name, last_name: FFaker::Name.name) }
  let!(:second_client) { create(:client, user: ec_case_worker, status: 'Active EC') }
  let!(:second_assessment) { create(:assessment, client: second_client, created_at: 7.months.ago) }

  let!(:fc_case_worker){ create(:user, roles: 'case worker', first_name: FFaker::Name.name, last_name: FFaker::Name.name) }
  let!(:third_client) { create(:client, user: fc_case_worker, status: 'Active FC') }
  let!(:third_assessment) { create(:assessment, client: third_client, created_at: Date.today << 6) }

  let!(:used_user) { create(:user) }
  let!(:other_clent) { create(:client, user: used_user) }
  let!(:case) { create(:case, user: used_user) }
  let!(:task) { create(:task, user: used_user) }
  let!(:changelog) { create(:changelog, user: used_user) }
  let!(:location){ create(:location, name: 'ផ្សេងៗ Other') }
  let!(:progress_note) { create(:progress_note, user: used_user, location: location) }

  let!(:kc_case_worker){ create(:user, roles: 'case worker', first_name: FFaker::Name.name, last_name: FFaker::Name.name) }
  let!(:fourth_client) { create(:client, user: kc_case_worker, status: 'Active KC') }
  let!(:fourth_assessment) { create(:assessment, client: fourth_client, created_at: Date.today << 6) }

  let!(:fifth_case_worker){ create(:user, roles: 'case worker', first_name: FFaker::Name.name, last_name: FFaker::Name.name) }
  let!(:fifth_client) { create(:client, user: fifth_case_worker, status: 'Referred') }
  let!(:fifth_assessment) { create(:assessment, client: fifth_client, created_at: Date.today << 6) }

  let!(:manager){ create(:user, roles: 'manager') }
  let!(:subordinate){ create(:user, roles: 'case worker', manager_id: manager.id) }
  let!(:strategic_overviewer){ create(:user, roles: 'strategic overviewer') }
  let!(:able_case_worker){ create(:user, roles: 'case worker') }
  let!(:able_client){ create(:client, user: able_case_worker, able_state: 'Accepted') }

  context 'no_any_associated_objects?' do
    it { expect(admin.no_any_associated_objects?).to be_truthy }
    it { expect(used_user.no_any_associated_objects?).to be_falsey }
  end

  context 'name' do
    it{ expect(case_worker.name).to eq('First Name Last Name') }
  end

  context 'admin?' do
    it{ expect(admin.admin?).to be_truthy }
    it{ expect(case_worker.admin?).to be_falsey }
  end

  context 'case_worker?' do
    it{ expect(case_worker.case_worker?).to be_truthy }
    it{ expect(admin.case_worker?).to be_falsey }
  end

  context 'assessment_either_overdue_or_due_today' do
    it{ expect(case_worker.assessment_either_overdue_or_due_today).to eq({overdue_count: 0, due_today_count: 0}) }
    it{ expect(ec_case_worker.assessment_either_overdue_or_due_today).to eq({overdue_count: 1, due_today_count: 0}) }
    it{ expect(fc_case_worker.assessment_either_overdue_or_due_today).to eq({overdue_count: 0, due_today_count: 1}) }
    it{ expect(kc_case_worker.assessment_either_overdue_or_due_today).to eq({overdue_count: 0, due_today_count: 1}) }
    it{ expect(fifth_case_worker.assessment_either_overdue_or_due_today).to eq({overdue_count: 0, due_today_count: 0}) }
  end

  context 'ec_manager?' do
    it { expect(ec_manager.ec_manager?).to be_truthy }
  end

  context 'fc_manager?' do
    it { expect(fc_manager.fc_manager?).to be_truthy }
  end

  context 'kc_manager?' do
    it { expect(kc_manager.kc_manager?).to be_truthy }
  end

  context 'able_manager?' do
    it { expect(able_manager.able_manager?).to be_truthy }
  end

  context 'any_case_manager?' do
    it { expect(ec_manager.any_case_manager?).to be_truthy }
    it { expect(fc_manager.any_case_manager?).to be_truthy }
    it { expect(kc_manager.any_case_manager?).to be_truthy }
  end

  context 'any_manager?' do
    it { expect(ec_manager.any_manager?).to be_truthy }
    it { expect(fc_manager.any_manager?).to be_truthy }
    it { expect(kc_manager.any_manager?).to be_truthy }
    it { expect(able_manager.any_manager?).to be_truthy }
  end

  context 'self_and_subordinates' do
    it 'current user is either Admin or Strategic Overviewer' do
      expect(User.self_and_subordinates(admin)).to include(admin, case_worker,
                                                          ec_manager, fc_manager,
                                                          kc_manager, able_manager,
                                                          ec_case_worker, fc_case_worker,
                                                          used_user, kc_case_worker,
                                                          fifth_case_worker, manager,
                                                          subordinate, strategic_overviewer,
                                                          able_case_worker)
    end
    it 'current user is Able Manager' do
      expect(User.self_and_subordinates(able_manager)).to include(able_manager, able_case_worker)
    end
    it 'current user is Ec Manager' do
      expect(User.self_and_subordinates(ec_manager)).to include(ec_manager, ec_case_worker)
    end
    it 'current user is Fc Manager' do
      expect(User.self_and_subordinates(fc_manager)).to include(fc_manager, fc_case_worker)
    end
    it 'current user is Kc Manager' do
      expect(User.self_and_subordinates(kc_manager)).to include(kc_manager, kc_case_worker)
    end
    it 'current user is Manager' do
      expect(User.self_and_subordinates(manager)).to include(manager, subordinate)
    end
  end
end
