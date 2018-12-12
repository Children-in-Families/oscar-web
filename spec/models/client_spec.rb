describe Client, 'associations' do

  it { is_expected.to belong_to(:referral_source) }
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:received_by) }
  it { is_expected.to belong_to(:followed_up_by) }
  it { is_expected.to belong_to(:birth_province) }

  # Client ask to hide #147254199
  # it { is_expected.to have_one(:government_report).dependent(:destroy) }
  # it { is_expected.to have_many(:surveys).dependent(:destroy) }

  it { is_expected.to have_many(:sponsors).dependent(:destroy) }
  it { is_expected.to have_many(:donors).through(:sponsors) }
  it { is_expected.to have_many(:cases).dependent(:destroy) }
  it { is_expected.to have_many(:tasks).dependent(:destroy) }
  it { is_expected.to have_many(:case_notes).dependent(:destroy) }
  it { is_expected.to have_many(:assessments).dependent(:destroy) }
  it { is_expected.to have_many(:agency_clients).dependent(:destroy) }
  it { is_expected.to have_many(:agencies).through(:agency_clients) }
  it { is_expected.to have_many(:client_quantitative_cases).dependent(:destroy) }
  it { is_expected.to have_many(:quantitative_cases).through(:client_quantitative_cases) }
  it { is_expected.to have_many(:custom_field_properties).dependent(:destroy) }
  it { is_expected.to have_many(:custom_fields).through(:custom_field_properties) }
  it { is_expected.to have_many(:users).through(:case_worker_clients) }
  it { is_expected.to have_many(:case_worker_clients).dependent(:destroy) }
  it { is_expected.to have_many(:exit_ngos).dependent(:destroy) }
  it { is_expected.to have_many(:enter_ngos).dependent(:destroy) }
  it { is_expected.to have_many(:referrals).dependent(:destroy) }
  it { is_expected.to have_many(:government_forms).dependent(:destroy) }
end

describe Client, 'callbacks' do
  before do
    ClientHistory.destroy_all
  end

  context 'set slug as alias' do
    let!(:client){ create(:client) }
    it { expect(client.slug).to eq("#{Organization.current.short_name}-#{client.id}") }
  end

  context 'create_client_history' do
    it 'should have two client histories' do
      client = FactoryGirl.create(:client)
      # 2 client_histories because client has an after_save callback to update slug column
      expect(ClientHistory.where('object.id' => client.id).count).to eq(1)
      expect(ClientHistory.where('object.id' => client.id).pluck(:id)).to eq(ClientHistory.all.pluck(:id))
    end

    it 'should have 2 client histories and 2 agency client histories each' do
      agencies      = FactoryGirl.create_list(:agency, 2)
      agency_client = FactoryGirl.create(:client, agency_ids: agencies.map(&:id))
      expect(ClientHistory.where('object.id' => agency_client.id).count).to eq(1)
      expect(ClientHistory.where('object.id' => agency_client.id).first.object['agency_ids']).to eq(agencies.map(&:id))
      expect(ClientHistory.where('object.id' => agency_client.id).last.object['agency_ids']).to eq(agencies.map(&:id))
      expect(ClientHistory.where('object.id' => agency_client.id).first.agency_client_histories.count).to eq(2)
      expect(ClientHistory.where('object.id' => agency_client.id).last.agency_client_histories.count).to eq(2)
    end
  end

  context 'before_create' do
    let!(:setting){ create(:setting, country_name: 'cambodia') }
    let!(:client_1){ create(:client) }
    context '#set_country_origin' do
      it 'base on Setting' do
        expect(client_1.country_origin).to eq('cambodia')
      end
    end
  end

  context 'before_update' do
    context 'if exiting_ngo?' do
      context 'disconnect_client_user_relation' do
        let!(:admin){ create(:user, :admin) }
        let!(:client){ create(:client, :accepted, user_ids: [admin.id]) }
        it { expect(client.user_ids.any?).to be_truthy }
        it 'remove user associaton' do
          client.update(exit_date: Date.today, exit_note: 'test', exit_circumstance: 'testing', status: 'Exited')
          client.reload
          expect(client.status).to eq('Exited')
          expect(client.user_ids.empty?).to be_truthy
          expect(client.case_worker_clients.empty?).to be_truthy
        end
      end
    end
  end
end

describe Client, 'methods' do
  let!(:setting){ create(:setting, :monthly_assessment) }
  let!(:case_worker) { create(:user, roles: 'case worker') }
  let!(:client){ create(:client, user_ids: [case_worker.id], local_given_name: 'Barry', local_family_name: 'Allen', date_of_birth: '2007-05-15', status: 'Active') }
  let!(:family){ create(:family) }
  let!(:other_client) { create(:client, user_ids: [case_worker.id]) }
  let!(:assessment){ create(:assessment, created_at: Date.today - 3.months, client: client) }
  let!(:custom_assessment){ create(:assessment, :custom, created_at: Date.today - 3.months, client: client) }
  let!(:client_a){ create(:client, code: Time.now.to_f.to_s.last(4) + rand(1..9).to_s, date_of_birth: '2017-05-05') }
  let!(:client_b){ create(:client, code: Time.now.to_f.to_s.last(4) + rand(1..9).to_s, date_of_birth: '2016-06-05') }
  let!(:client_c){ create(:client, code: Time.now.to_f.to_s.last(4) + rand(1..9).to_s, date_of_birth: '2016-06-06') }
  let!(:client_d){ create(:client, date_of_birth: '2015-10-06') }
  let!(:ec_case){ create(:case, client: client_a, case_type: 'EC') }
  let!(:fc_case){ create(:case, client: client_b, case_type: 'FC') }
  let!(:kc_case){ create(:case, client: client_c, case_type: 'KC') }
  let!(:exited_client){ create(:client, :exited) }

  before { Setting.first.update(enable_custom_assessment: true) }

  let!(:custom_assessment){ create(:assessment, :custom, created_at: Date.today - 3.months, client: client) }

  context '#family' do
    let!(:client_1){ create(:client, :accepted) }
    let!(:family_1){ create(:family, children: [client_1.id]) }
    it 'returns only a family of the client' do
      expect(client_1.family).to eq(family_1)
    end
  end

  context '#most_recent_csi_assessment' do
    it { expect(client.most_recent_csi_assessment).to eq(assessment.created_at.to_date) }
  end

  context '#most_recent_custom_csi_assessment' do
    it { expect(client.most_recent_custom_csi_assessment).to eq(custom_assessment.created_at.to_date) }
  end

  xcontext '.notify_upcoming_csi_assessment', skip: '====== Days of FEBRUARY ======' do
    subject { ActionMailer::Base.deliveries }

    after do
      subject.clear
    end

    context 'most recent csi is 3 months ago' do
      before do
        Client.notify_upcoming_csi_assessment
      end
      it 'does not send an email' do
        expect(subject.map(&:subject).include?('Upcoming CSI Assessment')).to be_falsey
      end
    end

    context 'most recent csi is 5.5 months ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email to case worker(s) of the client with subject: Upcoming CSI Assessment' do
        expect(subject.count).to eq(1)
        expect(subject.first.to).to include(case_worker.email)
        expect(subject.first.from).to eq([ENV['SENDER_EMAIL']])
        expect(subject.first.subject).to eq('Upcoming CSI Assessment')
      end
    end

    context 'most recent csi is 5.5 months and 1 week ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 1.week))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(subject.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 2 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 2.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(subject.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 3 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 3.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(subject.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 4 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 4.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(subject.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 5 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 5.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(subject.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 6 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 6.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(subject.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 7 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 7.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(subject.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 8 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 8.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(subject.count).to eq(1)
      end
    end
  end

  context 'exit_ngo?' do
    it { expect(exited_client.exit_ngo?).to be_truthy }
    it { expect(client.exit_ngo?).to be_falsey }
  end

  context 'active_case?' do
    it { expect(client_a.active_case?).to be_truthy }
    it { expect(client_b.active_case?).to be_truthy }
    it { expect(client_c.active_case?).to be_truthy }
  end

  context 'age' do
    let(:current_date) { '2017-06-05'.to_date }
    let(:dob)          { client.date_of_birth }
    it 'returns age of year' do
      expect(client.age_as_years(current_date)).to eq(10)
      expect(client_a.age_as_years(current_date)).to eq(0)
      expect(client_b.age_as_years(current_date)).to eq(1)
      expect(client_c.age_as_years(current_date)).to eq(0)
      expect(client_d.age_as_years(current_date)).to eq(1)
    end

    it 'returns age of month' do
      expect(client.age_extra_months(current_date)).to eq(0)
      expect(client_a.age_extra_months(current_date)).to eq(1)
      expect(client_b.age_extra_months(current_date)).to eq(0)
      expect(client_c.age_extra_months(current_date)).to eq(11)
      expect(client_d.age_extra_months(current_date)).to eq(7)
    end
  end

  context '#time_in_care' do
    let!(:program_stream) {  create(:program_stream) }

    context 'once enrollment' do
      let!(:client_enrollment) { create(:client_enrollment, enrollment_date: '2018-01-01', program_stream: program_stream, client: client) }
      let!(:leave_program) { create(:leave_program, exit_date: '2019-02-01', program_stream: program_stream, client_enrollment: client_enrollment) }
      it { expect(client.time_in_care).to eq({ years: 1, months: 1, weeks: 0, days: 0 }) }
    end

    context 'continuous enrollment' do
      let!(:first_enrollment) { create(:client_enrollment, enrollment_date: '2018-01-01', program_stream: program_stream, client: client) }
      let!(:leave_program) { create(:leave_program, exit_date: '2019-02-01', program_stream: program_stream, client_enrollment: first_enrollment) }
      let!(:second_enrollment) { create(:client_enrollment, enrollment_date: '2019-02-01', program_stream: program_stream, client: client) }
      let!(:second_leave_program) { create(:leave_program, exit_date: '2019-05-01', program_stream: program_stream, client_enrollment: second_enrollment) }

      it { expect(client.time_in_care).to eq({ years: 1, months: 4, weeks: 0, days: 0 }) }
    end

    context 'enrollments with one month delay' do
      let!(:first_enrollment) { create(:client_enrollment, enrollment_date: '2018-01-01', program_stream: program_stream, client: client) }
      let!(:leave_program) { create(:leave_program, exit_date: '2019-02-01', program_stream: program_stream, client_enrollment: first_enrollment) }
      let!(:second_enrollment) { create(:client_enrollment, enrollment_date: '2019-02-01', program_stream: program_stream, client: client) }
      let!(:second_leave_program) { create(:leave_program, exit_date: '2019-05-01', program_stream: program_stream, client_enrollment: second_enrollment) }
      let!(:third_enrollment) { create(:client_enrollment, enrollment_date: '2019-06-01', program_stream: program_stream, client: client) }
      let!(:third_leave_program) { create(:leave_program, exit_date: '2019-07-01', program_stream: program_stream, client_enrollment: third_enrollment) }

      it { expect(client.time_in_care).to eq({ years: 1, months: 5, weeks: 0, days: 0 }) }
    end
  end

  context 'assessment' do
    let!(:client_1){ create(:client, :accepted) }
    context '#next_assessment_date' do
      let!(:latest_assessment){ create(:assessment, client: client_1) }
      it 'last default assessment + maximum assessment duration' do
        expect(client_1.next_assessment_date).to eq((latest_assessment.created_at + (setting.max_assessment).months).to_date)
      end

      it 'should be today' do
        expect(other_client.next_assessment_date.start).to eq(Date.today.start)
      end
    end

    context '#custom_next_assessment_date' do
      let!(:latest_assessment){ create(:assessment, client: client_1, default: false) }
      it 'last custom assessment + maximum custom assessment duration' do
        expect(client_1.custom_next_assessment_date).to eq((latest_assessment.created_at + (setting.max_custom_assessment).months).to_date)
      end

      it 'should be today' do
        expect(other_client.custom_next_assessment_date.start).to eq(Date.today.start)
      end
    end
  end

  context '#can_create_assessment?(default)' do
    let!(:other_assessment){ create(:assessment, created_at: Date.today - 2.months, client: other_client) }
    let!(:no_csi_client){ create(:client, :accepted) }
    let!(:client_with_two_csi){ create(:client, :accepted) }
    let!(:assessment_1){ create(:assessment, created_at: Date.today - 3.months, client: client_with_two_csi) }
    let!(:assessment_2){ create(:assessment, created_at: Date.today, client: client_with_two_csi) }

    it { expect(client.can_create_assessment?(true)).to be_truthy }
    it { expect(no_csi_client.can_create_assessment?(true)).to be_truthy }
    it { expect(client_with_two_csi.can_create_assessment?(true)).to be_truthy }
    it { expect(other_client.can_create_assessment?(true)).to be_falsey }
  end

  context '#next_case_note_date' do
    let!(:client_1){ create(:client, :accepted) }
    let!(:lastest_case_note){ create(:case_note, client: client_1, meeting_date: Date.today) }
    let!(:case_note){ create(:case_note, client: other_client, meeting_date: 30.days.ago) }

    it 'should be last case note + 30 days' do
      expect(client_1.next_case_note_date).to eq((lastest_case_note.meeting_date + 30.days).to_date)
    end

    it 'should be today' do
      expect(other_client.next_case_note_date).to eq(Date.today)
    end
  end

  context 'age between' do
    let!(:follower){ create(:user)}
    let!(:province){ create(:province) }
    let!(:user){ create(:user) }
    let!(:specific_client){ create(:client,
      date_of_birth: 1.year.ago.to_date,
      received_by: user,
      followed_up_by: follower,
      birth_province: province,
      province: province,
      user_ids: [user.id],
      code: Time.now.to_f.to_s.last(4)
    )}
    let!(:other_specific_client){ create(:client,
      date_of_birth: 2.year.ago.to_date,
      received_by: user,
      followed_up_by: follower,
      birth_province: province,
      province: province,
      user_ids: [user.id],
      code: Time.now.to_f.to_s.last(4)
    )}

    min_age = 1
    max_age = 1.5
    it 'include clients with age between' do
      expect(Client.age_between(min_age, max_age)).to include(specific_client)
    end
    it 'does not include clients with age between' do
      expect(Client.age_between(min_age, max_age)).not_to include(other_specific_client)
    end
  end

  context 'name' do
    let!(:client_name) { create(:client, given_name: 'Adam', family_name: 'Eve') }
    let!(:client_local_name) { create(:client, given_name: '', family_name: '', local_given_name: 'Romeo', local_family_name: 'Juliet') }

    it 'return name' do
      expect(client_name.name).to eq("Adam Eve")
    end

    it 'reutrn local name' do
      expect(client_local_name.name).to eq("Romeo Juliet")
    end
  end

  context 'en and local name' do
    let!(:client) { create(:client, given_name: 'Adam', family_name: 'Eve', local_given_name: 'Juliet', local_family_name: 'Romeo') }
    it 'return english and local name' do
      expect(client.en_and_local_name).to eq("Adam Eve (Romeo Juliet)")
    end
  end

  context '#local_name' do
    let!(:client) { create(:client, given_name: 'Adam', family_name: 'Eve', local_given_name: 'Juliet', local_family_name: 'Romeo') }
    it 'return local name' do
      expect(client.local_name).to eq("Romeo Juliet")
    end
  end

  context 'age for csi' do
    before { Setting.first.update(enable_custom_assessment: true, age: 18, custom_age: 10) }
    let!(:client_1){ create(:client, date_of_birth: 10.years.ago) }
    let!(:client_2){ create(:client, date_of_birth: 5.years.ago) }
    context '#eligible_default_csi?' do
      it { expect(client_1.eligible_default_csi?).to be_truthy }
      it { expect(client_2.eligible_default_csi?).to be_truthy }
    end

    context '#eligible_custom_csi?' do
      it { expect(client_1.eligible_custom_csi?).to be_falsey }
      it { expect(client_2.eligible_custom_csi?).to be_truthy }
    end
  end
end

describe Client, 'scopes' do
  let!(:user){ create(:user, :admin) }
  let!(:follower){ create(:user)}
  let!(:referral_source) { create(:referral_source)}
  let!(:province){ create(:province) }
  let!(:district){ create(:district) }
  let!(:client){ create(:client, :accepted,
    slug: 'Example id',
    given_name: 'Example First Name',
    family_name: 'Example Last Name',
    local_given_name: 'Example Local First Name',
    local_family_name: 'Example Local Last Name',
    school_name: 'Example school',
    school_grade: 'Example grade',
    referral_phone: '012678779',
    relevant_referral_information: 'Example Info',
    referral_source: referral_source,
    received_by: user,
    gender: 'female',
    followed_up_by: follower,
    birth_province: province,
    province: province,
    user_ids: [user.id],
    district: district,
    telephone_number: '010123456',
    code: Time.now.to_f.to_s.last(4)
  )}
  let!(:assessment) { create(:assessment, client: client) }
  let!(:other_client){ create(:client, :exited) }

  let(:kc_client) { create(:client, :accepted) }
  let(:fc_client) { create(:client, :accepted) }
  let(:ec_client) { create(:client, :accepted) }
  let!(:kc) { create(:case, client: kc_client, case_type: 'KC') }
  let!(:fc) { create(:case, client: fc_client, case_type: 'FC') }
  let!(:exited_client){ create(:client, :exited) }

  context 'exited_ngo' do
    subject { Client.exited_ngo }
    it 'include clients who exited from NGO' do
      is_expected.to include(exited_client)
      is_expected.not_to include(kc_client, fc_client, ec_client)
    end
  end

  context 'non_exited_ngo' do
    subject { Client.non_exited_ngo }
    it 'include clients who have NOT exited from NGO' do
      is_expected.to include(kc_client, fc_client)
      is_expected.not_to include(exited_client)
    end
  end

  context 'given name like' do
    let!(:clients){ Client.given_name_like(client.given_name) }
    it 'should include record have given name like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have given name like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'family name like' do
    let!(:clients){ Client.family_name_like(client.family_name) }
    it 'should include record have family name like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have family name like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'local given name like' do
    let!(:clients){ Client.local_given_name_like(client.local_given_name) }
    it 'should include record have local given name like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have local given name like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'local family name like' do
    let!(:clients){ Client.local_family_name_like(client.local_family_name) }
    it 'should include record have local family name like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have local family name like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'active_accepted_status' do
    it 'have all active and accepted clients' do
      expect(Client.active_accepted_status).to include(client, kc_client, fc_client, ec_client)
    end
  end

  context 'active' do
    it 'have all active clients' do
      expect(Client.active_status.count).to eq(2)
    end
  end

  context 'without assessments' do
    it 'should include record without any assessments' do
      expect(Client.without_assessments).to include(other_client)
    end

    it 'should not include record with any assessments' do
      expect(Client.without_assessments).not_to include(client)
    end
  end

  context 'is received by' do
    let!(:received_by){ [user.name, user.id] }
    let!(:is_received_by){ Client.is_received_by }
    it 'should return username and id' do
      expect(is_received_by).to include(received_by)
    end
  end

  context 'referral source is' do
    let!(:referral_sources){ [referral_source.name, referral_source.id] }
    let!(:referral_source_is){ Client.referral_source_is }
    it 'should return referral source name and id' do
      expect(referral_source_is).to include(referral_sources)
    end
  end

  context 'is follow up by' do
    let!(:follow_up){ [follower.name, follower.id] }
    let!(:is_followed_up_by){ Client.is_followed_up_by }
    it 'should return follower name and id' do
      expect(is_followed_up_by).to include(follow_up)
    end
  end

  context 'birth province is' do
    let!(:birth_province){ [province.name, province.id] }
    let!(:birth_province_is){ Client.birth_province_is }
    it 'should return birth province name and id' do
      expect(birth_province_is).to include(birth_province)
    end
  end

  context 'province is' do
    let!(:provinces){ [province.name, province.id] }
    let!(:province_is){ Client.province_is }
    it 'should return province name and id' do
      expect(province_is).to include(provinces)
    end
  end

  context 'case worker is' do
    let!(:case_worker){ [user.name, user.id] }
    let!(:case_worker_is){ Client.case_worker_is }
    xit 'should return case worker name and id' do
      expect(case_worker_is).to include(case_worker)
    end
  end

  context 'gender' do
    it 'male' do
      expect(Client.male).to include(other_client)
    end
    it 'female' do
      expect(Client.female).to include(client)
    end
  end

  context 'id like' do
    let!(:clients){ Client.slug_like(client.slug.downcase) }
    it 'should include record have id like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have id like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'find by family id' do
    let(:family) { create(:family) }
    let!(:kc) { create(:case, client: client, case_type: 'KC', family: family) }
    let!(:fc) { create(:case, client: client, case_type: 'FC', family: family) }

    it 'should return client that has cases has family' do
      expect(Client.find_by_family_id(family.id)).to eq [client]
    end
  end
end

describe 'validations' do
  it { is_expected.to validate_presence_of(:initial_referral_date) }
  it { is_expected.to validate_presence_of(:received_by_id) }
  it { is_expected.to validate_presence_of(:referral_source) }
  it { is_expected.to validate_presence_of(:name_of_referee) }
  it { is_expected.to validate_presence_of(:gender) }

  subject { FactoryGirl.build(:client) }

  context 'user_ids' do
    context 'on create' do
      it { is_expected.to validate_presence_of(:user_ids) }
    end
    context 'on update unless exit_ngo' do
      let!(:admin){ create(:user, :admin) } # required this object for the email to be sent
      let!(:client){ create(:client, :accepted) }
      let!(:exit_client){ create(:client, :exited) }
      context 'no validate if exit ngo' do
        before do
          exit_client.user_ids = []
        end
        it { expect(exit_client.valid?).to be_truthy }
      end

      context 'validate if not exit ngo' do
        before do
          client.user_ids = []
        end
        it { expect(client.valid?).to be_falsey }
      end
    end
  end

  context 'kid_id' do
    subject{ FactoryGirl.build(:client) }
    let!(:user){ create(:user) }
    let!(:client){ create(:client, kid_id: 'STID-01', user_ids: [user.id]) }
    let!(:valid_client){ build(:client, user_ids: [user.id]) }
    let!(:invalid_client){ build(:client, kid_id: 'stid-01', user_ids: [user.id]) }
    before { subject.kid_id = 'STiD-01' }
    it { is_expected.to validate_uniqueness_of(:kid_id).case_insensitive }
    it { expect(valid_client).to be_valid }
    it { expect(invalid_client).to be_invalid }
  end
end
