describe User, 'associations' do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:department) }

  it { is_expected.to have_one(:permission).dependent(:destroy) }

  it { is_expected.to have_many(:advanced_searches).dependent(:destroy) }
  it { is_expected.to have_many(:calendars).dependent(:destroy) }
  it { is_expected.to have_many(:visits).dependent(:destroy) }
  it { is_expected.to have_many(:visit_clients).dependent(:destroy) }
  it { is_expected.to have_many(:tasks).dependent(:destroy) }
  it { is_expected.to have_many(:clients).through(:case_worker_clients) }
  it { is_expected.to have_many(:case_worker_clients).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:changelogs).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:custom_field_properties).dependent(:destroy) }
  it { is_expected.to have_many(:custom_fields).through(:custom_field_properties) }
  it { is_expected.to have_many(:custom_field_permissions).dependent(:destroy) }
  it { is_expected.to have_many(:user_custom_field_permissions).through(:custom_field_permissions) }
  it { is_expected.to have_many(:program_stream_permissions).dependent(:destroy) }
  it { is_expected.to have_many(:program_streams).through(:program_stream_permissions) }
  it { is_expected.to have_many(:quantitative_type_permissions).dependent(:destroy) }
  it { is_expected.to have_many(:quantitative_types).through(:quantitative_type_permissions) }
  it { is_expected.to have_many(:enter_ngo_users).dependent(:destroy) }
  it { is_expected.to have_many(:enter_ngos).through(:enter_ngo_users) }
  it { is_expected.to have_many(:families).dependent(:nullify) }
end

describe User, 'validations' do
  it { is_expected.to validate_presence_of(:roles) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_inclusion_of(:roles).in_array(User::ROLES) }
end

describe User, 'callbacks' do
  context 'before_save' do
    let!(:manager_1){ create(:user, :manager) }
    let!(:manager_2){ create(:user, :manager, manager_id: manager_1.id) }
    let(:case_worker){ create(:user, manager_id: manager_2.id) }

    context 'detach_manager' do
      context 'reset manager_id to nil' do
        it 'if roles_changed to admin' do
          case_worker.update(roles: 'admin')
          expect(case_worker.manager_id).to be_nil
          expect(case_worker.manager_ids).to eq([])
        end

        it 'if roles_changed to strategic_overviewer' do
          case_worker.update(roles: 'strategic overviewer')
          expect(case_worker.manager_id).to be_nil
          expect(case_worker.manager_ids).to eq([])
        end
      end
    end
  end

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

  context 'reset_manager' do
    let!(:manager){ create(:user, :manager) }
    let!(:case_worker){ create(:user, :case_worker, manager_id: manager.id) }

    it 'should reset manager if manager is changed to strategic overviewer' do
      manager.update(roles: 'strategic overviewer')
      case_worker.reload
      expect(case_worker.manager_id).to be_nil
    end

    it 'should reset manager if manager is changed to case worker' do
      manager.update(roles: 'case worker')
      case_worker.reload
      expect(case_worker.manager_id).to be_nil
    end

    it 'should not reset manager if manager is changed to other manager or admin' do
      manager.update(roles: 'admin')
      case_worker.reload
      expect(case_worker.manager_id).to eq(manager.id)
    end
  end

  context 'multiple manager' do
    let!(:manager_level_3){ create(:user, :manager) }
    let!(:manager_level_2){ create(:user, :manager) }
    let!(:manager_level_1){ create(:user, :manager) }
    let!(:other_manager){ create(:user, :manager) }
    let!(:case_worker){ create(:user, :case_worker, manager_id: manager_level_1.id) }
    it 'create a case_worker managed by manager level_1' do
      expect(case_worker.manager_ids).to include(manager_level_1.id)
    end

    it "update manager level_1 managed_by manager level_2" do
      manager_level_1.update(manager_id: manager_level_2.id)
      expect(manager_level_1.manager_ids).to include(manager_level_2.id)
      expect(case_worker.reload.manager_ids).to include(manager_level_1.id, manager_level_2.id)
    end

    it "update manager level_2 managed_by manager level_3" do
      manager_level_1.update(manager_id: manager_level_2.id)
      manager_level_2.update(manager_id: manager_level_3.id)
      expect(manager_level_2.manager_ids).to include(manager_level_3.id)
      expect(manager_level_1.reload.manager_ids).to include(manager_level_2.id, manager_level_3.id)
      expect(case_worker.reload.manager_ids).to include(manager_level_1.id, manager_level_2.id, manager_level_3.id)
    end

    it "update manager A to manager B" do
      manager_level_1.update(manager_id: manager_level_2.id)
      manager_level_2.update(manager_id: manager_level_3.id)
      case_worker.update(manager_id: other_manager.id)
      expect(case_worker.manager_ids).not_to include(manager_level_1.id, manager_level_2.id, manager_level_3.id)
    end

    it "update case worker manager manager_level_1 to other_manager" do
      other_manager.update(manager_id: manager_level_2.id)
      manager_level_2.update(manager_id: manager_level_3.id)
      case_worker.update(manager_id: other_manager.id)
      expect(case_worker.manager_ids).to include(other_manager.id, manager_level_2.id, manager_level_3.id)
    end
  end

  context 'build permission' do
    let!(:client) { create(:client) }
    let!(:assessment) { create(:assessment, client: client) }
    let!(:case_note) { create(:case_note, client: client, assessment: assessment) }
    let!(:custom_field) { create(:custom_field) }
    let!(:program_stream) { create(:program_stream) }

    let!(:user) { create(:user) }

    it 'create a record in permission' do
      expect(user.permission).to be_truthy
      expect(user.permission.case_notes_readable).to eq(true)
      expect(user.permission.case_notes_editable).to eq(true)
      expect(user.permission.assessments_readable).to eq(true)
      expect(user.permission.assessments_editable).to eq(true)
    end

    it 'create records in custom field permission' do
      expect(user.custom_field_permissions.first.user_id).to eq(user.id)
      expect(user.custom_field_permissions.first.custom_field_id).to eq(custom_field.id)
      expect(user.custom_field_permissions.first.readable).to eq(true)
      expect(user.custom_field_permissions.first.editable).to eq(true)
    end

    it 'create records in program stream permission' do
      expect(user.program_stream_permissions.first.user_id).to eq(user.id)
      expect(user.program_stream_permissions.first.program_stream_id).to eq(program_stream.id)
      expect(user.program_stream_permissions.first.readable).to eq(true)
      expect(user.program_stream_permissions.first.editable).to eq(true)
    end
  end

  context 'toggle_referral_notification' do
    let!(:admin) { create(:user, :admin) }
    let!(:manager) { create(:user, :manager) }

    it 'should update admin recive referral to true' do
      expect(admin.referral_notification).to be_truthy
    end

    it 'should update manager recive referral to false' do
      expect(manager.referral_notification).to be_falsey
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
    province: province,
    gender: 'female'
  ) }
  let!(:other_user){ create(:user, department: department, province: province, gender: 'male') }
  let!(:no_department_user){ create(:user, province: province) }
  let!(:user_in_other_department){ create(:user,department: other_department, province: province) }
  let!(:manager){ create(:user, :manager, staff_performance_notification: false) }
  let!(:not_notify_email){ create(:user, task_notify: false) }

  context '.non_devs' do
    let!(:dev_1) { create(:user, email: ENV['DEV_EMAIL']) }
    it 'exclude developers' do
      expect(User.non_devs).not_to include(dev_1)
    end
  end

  context '.non_locked' do
    let!(:locked_user) { create(:user, disable: true) }

    it 'exclude locked user' do
      expect(User.non_locked).not_to include(locked_user)
    end
  end

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

  context '.males' do
    it 'returns male users' do
      expect(User.males.ids).to include(other_user.id)
      expect(User.males.ids).not_to include(user.id)
    end
  end

  context '.females' do
    it 'returns female users' do
      expect(User.females.ids).to include(user.id)
      expect(User.females.ids).not_to include(other_user.id)
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

  context 'province are' do
    subject{ User.province_are }

    it 'should include province' do
      province_array = [province.name, province.id]
      is_expected.to include(province_array)
    end
  end

  context 'has clients' do
    let!(:client) { create(:client, users: [other_user]) }
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

  context 'staff_performance' do
    subject{ User.staff_performances }
    it 'should include staff performance' do
      is_expected.to include(user, other_user, no_department_user, user_in_other_department)
    end
    it 'should not include staff performance' do
      is_expected.not_to include(manager)
    end
  end

  context 'notify_email' do
    subject{ User.notify_email }
    it 'should include notify emails' do
      is_expected.to include(user, other_user, no_department_user, user_in_other_department)
    end
    it 'should not include notify emails' do
      is_expected.not_to include(not_notify_email)
    end
  end

  context 'referral_notification_email' do
    subject{ User.referral_notification_email }
    it 'should include referral notification user' do
      is_expected.to include(user)
    end
    it 'should not include referral notification user' do
      is_expected.not_to include(manager)
    end
  end
end

describe User, 'methods' do
  let!(:admin){ create(:user, roles: 'admin') }
  let!(:case_worker){ create(:user, roles: 'case worker', first_name: 'First Name', last_name: 'Last Name') }
  let!(:unknown_user){ create(:user, first_name: '', last_name: '') }

  let!(:client) { create(:client, :accepted, users: [case_worker]) }
  let!(:assessment) { create(:assessment, client: client, created_at: Date.today) }

  let!(:used_user) { create(:user) }
  let!(:other_clent) { create(:client, :accepted, users: [used_user]) }
  let!(:task) { create(:task, user: used_user) }
  let!(:changelog) { create(:changelog, user: used_user) }

  let!(:fifth_case_worker){ create(:user, roles: 'case worker', first_name: FFaker::Name.name, last_name: FFaker::Name.name) }
  let!(:fifth_client) { create(:client, users: [fifth_case_worker], status: 'Referred') }
  let!(:fifth_assessment) { create(:assessment, client: fifth_client, created_at: Date.today << 6) }

  let!(:manager){ create(:user, roles: 'manager') }
  let!(:subordinate){ create(:user, roles: 'case worker', manager_id: manager.id) }
  let!(:strategic_overviewer){ create(:user, roles: 'strategic overviewer') }
  let!(:able_case_worker){ create(:user, roles: 'case worker') }
  let!(:able_client){ create(:client, users: [able_case_worker], able_state: 'Accepted') }
  before do
    Setting.first.update(enable_custom_assessment: false)
  end

  context 'no_any_associated_objects?' do
    it { expect(admin.no_any_associated_objects?).to be_truthy }
    it { expect(used_user.no_any_associated_objects?).to be_falsey }
  end

  context 'name' do
    it{ expect(case_worker.name).to eq('First Name Last Name') }
    it{ expect(unknown_user.name).to eq(' ') }
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
    it{ expect(case_worker.assessment_either_overdue_or_due_today).to eq({overdue_count: 0, due_today_count: 0, custom_overdue_count: 0, custom_due_today_count: 0}) }
    it{ expect(fifth_case_worker.assessment_either_overdue_or_due_today).to eq({overdue_count: 0, due_today_count: 0, custom_overdue_count: 0, custom_due_today_count: 0}) }
  end

  context 'self_and_subordinates' do
    it 'current user is either Admin or Strategic Overviewer' do
      expect(User.self_and_subordinates(admin)).to include(admin, case_worker,
                                                          used_user, fifth_case_worker, manager,
                                                          subordinate, strategic_overviewer)
    end
    it 'current user is Manager' do
      expect(User.self_and_subordinates(manager)).to include(manager, subordinate)
    end
  end
end
