describe Client, 'associations' do

  it { is_expected.to belong_to(:referral_source) }
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:received_by) }
  it { is_expected.to belong_to(:followed_up_by) }
  it { is_expected.to belong_to(:birth_province) }
  it { is_expected.to belong_to(:donor) }

  # Client ask to hide #147254199
  # it { is_expected.to have_one(:government_report).dependent(:destroy) }
  # it { is_expected.to have_many(:surveys).dependent(:destroy) }

  it { is_expected.to have_many(:cases).dependent(:destroy) }
  it { is_expected.to have_many(:tasks).dependent(:destroy) }
  it { is_expected.to have_many(:case_notes).dependent(:destroy) }
  it { is_expected.to have_many(:assessments).dependent(:destroy) }
  it { is_expected.to have_many(:progress_notes).dependent(:destroy) }
  it { is_expected.to have_many(:agency_clients) }
  it { is_expected.to have_many(:agencies).through(:agency_clients) }
  it { is_expected.to have_many(:client_quantitative_cases).dependent(:destroy) }
  it { is_expected.to have_many(:quantitative_cases).through(:client_quantitative_cases) }
  it { is_expected.to have_many(:custom_field_properties).dependent(:destroy) }
  it { is_expected.to have_many(:custom_fields).through(:custom_field_properties) }
  it { is_expected.to have_many(:users).through(:case_worker_clients) }
  it { is_expected.to have_many(:case_worker_clients).dependent(:destroy) }

  it { is_expected.to have_many(:client_client_types).dependent(:destroy) }
  it { is_expected.to have_many(:client_types).through(:client_client_types) }
  it { is_expected.to have_many(:client_needs).dependent(:destroy) }
  it { is_expected.to have_many(:needs).through(:client_needs) }
  it { is_expected.to have_many(:client_interviewees).dependent(:destroy) }
  it { is_expected.to have_many(:interviewees).through(:client_interviewees) }
  it { is_expected.to have_many(:client_problems).dependent(:destroy) }
  it { is_expected.to have_many(:problems).through(:client_problems) }
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
      expect(ClientHistory.where('object.id' => client.id).count).to eq(2)
      expect(ClientHistory.where('object.id' => client.id).pluck(:id)).to eq(ClientHistory.all.pluck(:id))
    end

    it 'should have 2 client histories and 2 agency client histories each' do
      agencies      = FactoryGirl.create_list(:agency, 2)
      agency_client = FactoryGirl.create(:client, agency_ids: agencies.map(&:id))
      expect(ClientHistory.where('object.id' => agency_client.id).count).to eq(2)
      expect(ClientHistory.where('object.id' => agency_client.id).first.object['agency_ids']).to eq(agencies.map(&:id))
      expect(ClientHistory.where('object.id' => agency_client.id).last.object['agency_ids']).to eq(agencies.map(&:id))
      expect(ClientHistory.where('object.id' => agency_client.id).first.agency_client_histories.count).to eq(2)
      expect(ClientHistory.where('object.id' => agency_client.id).last.agency_client_histories.count).to eq(2)
    end
  end
end

describe Client, 'methods' do
  let!(:able_manager) { create(:user, roles: 'able manager') }
  let!(:case_worker) { create(:user, roles: 'case worker') }
  let!(:client){ create(:client, user_ids: [case_worker.id], local_given_name: 'Barry', local_family_name: 'Allen', date_of_birth: '2007-05-15', status: 'Active') }
  let!(:other_client) { create(:client, user_ids: [case_worker.id]) }
  let!(:able_client) { create(:client, able_state: Client::ABLE_STATES[0]) }
  let!(:able_manager_client) { create(:client, user_ids: [able_manager.id]) }
  let!(:assessment){ create(:assessment, created_at: Date.today - 3.months, client: client) }
  let!(:able_rejected_client) { create(:client, able_state: Client::ABLE_STATES[1]) }
  let!(:able_discharged_client) { create(:client, able_state: Client::ABLE_STATES[2]) }
  let!(:client_a){ create(:client, date_of_birth: '2017-05-05') }
  let!(:client_b){ create(:client, date_of_birth: '2016-06-05') }
  let!(:client_c){ create(:client, date_of_birth: '2016-06-06') }
  let!(:client_d){ create(:client, date_of_birth: '2015-10-06') }
  let!(:ec_case){ create(:case, client: client_a, case_type: 'EC') }
  let!(:fc_case){ create(:case, client: client_b, case_type: 'FC') }
  let!(:kc_case){ create(:case, client: client_c, case_type: 'KC') }
  let!(:exited_client){ create(:client, status: Client::EXIT_STATUSES.first) }

  context '#most_recent_csi_assessment' do
    it { expect(client.most_recent_csi_assessment).to eq(assessment.created_at.to_date) }
  end

  context '.notify_upcoming_csi_assessment' do
    after do
      ActionMailer::Base.deliveries.clear
    end

    context 'most recent csi is 3 months ago' do
      before do
        Client.notify_upcoming_csi_assessment
      end
      it 'does not send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end

    context 'most recent csi is 5.5 months ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email to case worker(s) of the client with subject: Upcoming CSI Assessment' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        expect(ActionMailer::Base.deliveries.first.to).to include(case_worker.email)
        expect(ActionMailer::Base.deliveries.first.from).to eq([ENV['SENDER_EMAIL']])
        expect(ActionMailer::Base.deliveries.first.subject).to eq('Upcoming CSI Assessment')
      end
    end

    context 'most recent csi is 5.5 months and 1 week ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 1.week))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 2 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 2.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 3 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 3.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 4 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 4.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 5 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 5.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 6 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 6.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 7 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 7.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end

    context 'most recent csi is 5.5 months and 8 weeks ago' do
      before do
        assessment.update(created_at: (Date.today - 5.months - 15.days - 8.weeks))
        Client.notify_upcoming_csi_assessment
      end

      it 'send an email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end
    end
  end

  context 'exit_ngo?' do
    it { expect(exited_client.exit_ngo?).to be_truthy }
    it { expect(client.exit_ngo?).to be_falsey }
  end

  context 'active_ec?' do
    it { expect(client_a.active_ec?).to be_truthy }
  end

  context 'active_fc?' do
    it { expect(client_b.active_fc?).to be_truthy }
  end

  context 'active_kc?' do
    it { expect(client_c.active_kc?).to be_truthy }
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

  context 'time in care' do
    context 'without any cases' do
      it { expect(client.time_in_care).to be_nil }
    end

    context 'with an active case' do
      let!(:case) { create(:case, client: client, exited: false, start_date: 1.year.ago) }
      it { expect(client.time_in_care).to eq(1.0) }
    end

    context 'with inactive case' do
      let!(:case) { create(:case, client: client, exited: true, start_date: 2.years.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
      it { expect(client.time_in_care).to eq(2.0) }
    end

    context 'with an inactive case and an active case' do
      let!(:inactive_case) { create(:case, client: client, exited: true, start_date: 2.years.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
      let!(:active_case) { create(:case, client: client, exited: false, start_date: 6.months.ago) }
      it { expect(client.time_in_care).to eq(0.5) }
    end

    context 'with an inactive case and two active cases' do
      let!(:inactive_case) { create(:case, client: client, exited: true, start_date: 2.years.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
      let!(:active_case) { create(:case, client: client, exited: false, start_date: 1.year.ago) }
      let!(:other_active_case) { create(:case, case_type: 'FC', client: client, exited: false, start_date: 6.months.ago) }
      it { expect(client.time_in_care).to eq(1.0) }
    end

    context 'with some inactive cases and an active case' do
      let!(:inactive_case) { create(:case, client: client, exited: true, start_date: 2.years.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
      let!(:active_case) { create(:case, client: client, exited: false, start_date: 1.year.ago) }
      let!(:other_active_case) { create(:case, case_type: 'FC', client: client, exited: true, start_date: 6.months.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
      it { expect(client.time_in_care).to eq(1.0) }
    end

    context 'without any active cases but some inactive cases' do
      let!(:inactive_case) { create(:case, client: client, exited: true, start_date: 2.years.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
      let!(:active_case) { create(:case, case_type: 'FC', client: client, exited: true, start_date: 6.months.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
      it { expect(client.time_in_care).to eq(2.0) }
    end
  end

  context 'active_day_care' do
    let!(:case) { create(:case, client: client, exited: false, start_date: 10.day.ago) }
    it { expect(client.active_day_care).to eq(10) }
  end

  context 'inactive_day_care' do
    let!(:inactive_case) { create(:case, client: client, exited: true, start_date: 2.years.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
    let!(:active_case) { create(:case, case_type: 'FC', client: client, exited: true, start_date: 6.months.ago, exit_date: Date.today, exit_note: FFaker::Lorem.paragraph) }
    it { expect(client.inactive_day_care).to eq(731.0) }
  end

  context '#next_assessment_date' do
    let!(:client_1){ create(:client, :accepted) }
    let!(:latest_assessment){ create(:assessment, client: client_1) }
    it 'should be last assessment + 6 months' do
      expect(client_1.next_assessment_date).to eq((latest_assessment.created_at + 6.months).to_date)
    end

    it 'should be today' do
      expect(other_client.next_assessment_date.start).to eq(Date.today.start)
    end
  end

  context '#can_create_assessment?' do
    let!(:other_assessment){ create(:assessment, created_at: Date.today - 2.months, client: other_client) }
    let!(:no_csi_client){ create(:client, :accepted) }
    let!(:client_with_two_csi){ create(:client, :accepted) }
    let!(:assessment_1){ create(:assessment, created_at: Date.today - 3.months, client: client_with_two_csi) }
    let!(:assessment_2){ create(:assessment, created_at: Date.today, client: client_with_two_csi) }

    it { expect(client.can_create_assessment?).to be_truthy }
    it { expect(no_csi_client.can_create_assessment?).to be_truthy }
    it { expect(client_with_two_csi.can_create_assessment?).to be_truthy }
    it { expect(other_client.can_create_assessment?).to be_falsey }
  end

  context 'age between' do
    let!(:follower){ create(:user)}
    let!(:province){ create(:province) }
    let!(:user){ create(:user) }
    let!(:specific_client){ create(:client,
      date_of_birth: 1.year.ago.to_date,
      received_by: user,
      state: 'accepted',
      followed_up_by: follower,
      birth_province: province,
      province: province,
      user_ids: [user.id]
    )}
    let!(:other_specific_client){ create(:client,
      date_of_birth: 2.year.ago.to_date,
      received_by: user,
      state: 'accepted',
      followed_up_by: follower,
      birth_province: province,
      province: province,
      user_ids: [user.id]
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

  context 'in any able states managed by user' do
    it 'returns clients either in any able states or managed by current user' do
      expect(Client.in_any_able_states_managed_by(able_manager)).to include(able_client, able_manager_client, able_rejected_client, able_discharged_client)
    end
    it 'does not return neither non able clients nor not managed by current user' do
      expect(Client.in_any_able_states_managed_by(case_worker)).not_to include(able_manager_client)
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
    let!(:client) { create(:client, given_name: 'Adam', family_name: 'Eve', local_given_name: 'Romeo', local_family_name: 'Juliet') }
    it 'return english and local name' do
      expect(client.en_and_local_name).to eq("Adam Eve (Romeo Juliet)")
    end
  end
end

describe Client, 'scopes' do
  let!(:user){ create(:user, :admin) }
  let!(:follower){ create(:user)}
  let!(:referral_source) { create(:referral_source)}
  let!(:province){ create(:province) }
  let!(:district){ create(:district) }
  let!(:client){ create(:client,
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
    state: 'accepted',
    gender: 'female',
    followed_up_by: follower,
    birth_province: province,
    province: province,
    user_ids: [user.id],
    district: district,
    telephone_number: '010123456'
  )}
  let!(:assessment) { create(:assessment, client: client) }
  let!(:other_client){ create(:client, state: 'rejected') }
  let!(:able_client) { create(:client, able_state: Client::ABLE_STATES[0]) }

  let(:kc_client) { create(:client, status: 'Active KC', state: 'accepted') }
  let(:fc_client) { create(:client, status: 'Active FC', state: 'accepted') }
  let(:ec_client) { create(:client, status: 'Referred', state: 'accepted') }
  let!(:kc) { create(:case, client: kc_client, case_type: 'KC') }
  let!(:fc) { create(:case, client: fc_client, case_type: 'FC') }
  let!(:exited_client){ create(:client, status: Client::EXIT_STATUSES.first) }

  context 'exited_ngo' do
    subject { Client.exited_ngo }
    it 'include clients who exited from NGO' do
      is_expected.to include(exited_client)
      is_expected.not_to include(kc_client, fc_client, ec_client)
    end
  end

  context 'telephone_number_like' do
    subject { Client.telephone_number_like('010123456') }
    it 'include clients who have phone number like' do
      is_expected.to include(client)
      is_expected.not_to include(kc_client, fc_client, ec_client)
    end
  end

  context 'non_exited_ngo' do
    subject { Client.non_exited_ngo }
    it 'include clients who have NOT exited from NGO' do
      is_expected.to include(kc_client, fc_client, ec_client)
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

  context 'active' do
    it 'have all active clients' do
      expect(Client.all_active_types.count).to eq(2)
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

  context 'current address like' do
    let!(:clients){ Client.current_address_like(client.current_address.downcase[0, 10]) }
    it 'should include record have address like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have address like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'house number like' do
    let!(:clients){ Client.house_number_like(client.house_number.downcase[0, 5]) }
    it 'should include record have house number like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have house number like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'street number like' do
    let!(:clients){ Client.street_number_like(client.street_number.downcase[0, 5]) }
    it 'should include record have street number like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have street number like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'village like' do
    let!(:clients){ Client.village_like(client.village.downcase[0, 5]) }
    it 'should include record have village like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have village like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'commune like' do
    let!(:clients){ Client.commune_like(client.commune.downcase[0, 5]) }
    it 'should include record have commune like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have commune like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'district like' do
    let!(:clients){ Client.district_like(district.name) }
    it 'should include record have district like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have district like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'school name like' do
    let!(:clients){ Client.school_name_like(client.school_name.downcase) }
    it 'should include record have school name like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have school name like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'referral phone like' do
    let!(:clients){ Client.referral_phone_like(client.referral_phone.downcase) }
    it 'should include record have referral phone like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have referral phone like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'info like' do
    let!(:clients){ Client.info_like(client.relevant_referral_information.downcase[0, 10]) }
    it 'should include record have info like' do
      expect(clients).to include(client)
    end
    it 'should not include record not have info like' do
      expect(clients).not_to include(other_client)
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
    xit 'should return birth province name and id' do
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

  context 'state' do
    it 'accepted' do
      expect(Client.accepted).to include(client)
    end
    it 'rejected' do
      expect(Client.rejected).to include(other_client)
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

  context 'start with code' do
    let(:kc_client) { create(:client, status: 'Active KC', state: 'accepted') }
    let(:fc_client) { create(:client, status: 'Active FC', state: 'accepted') }
    let!(:kc) { create(:case, client: kc_client, case_type: 'KC') }
    let!(:fc) { create(:case, client: fc_client, case_type: 'FC') }

    it 'should return active kc case with code start from 2' do
      expect(Client.start_with_code(2).count).to eq 1
      expect(Client.start_with_code(2).first.code).to eq '2000'
    end

    it 'should return active fc case with code start from 1' do
      expect(Client.start_with_code(1).count).to eq 1
      expect(Client.start_with_code(1).first.code).to eq '1000'
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

  context 'able states' do
    states = %w(Accepted Rejected Discharged)
    it 'return all three able states' do
      expect(Client::ABLE_STATES).to eq(states)
    end
  end

  context 'able' do
    it 'should return able client' do
      expect(Client.able).to include(able_client)
    end
    it 'should not return non able client' do
      expect(Client.able).not_to include([client, other_client])
    end
  end

  context 'kid_id_like' do
    let!(:client)       { create(:client, kid_id: 'K000001') }
    let!(:other_client) { create(:client, kid_id: 'K000002') }
    let!(:clients)      { Client.kid_id_like('000001') }
    it 'should include records with kid_id like' do
      expect(clients).to include(client)
    end
    it 'should not include records without kid_id like' do
      expect(clients).not_to include(other_client)
    end
  end

  context 'live_with_like' do
    let!(:client)       { create(:client, live_with: 'Rainy') }
    let!(:other_client) { create(:client, live_with: 'Nico') }
    let!(:clients)      { Client.live_with_like('rain') }
    it 'should include records with live_with like' do
      expect(clients).to include(client)
    end
    it 'should not include records without live_with like' do
      expect(clients).not_to include(other_client)
    end
  end
end

describe 'validations' do
  context 'rejected_note' do
    let!(:client){ create(:client, state: '', rejected_note: '') }
    before do
      client.state = 'rejected'
      client.rejected_note = ''
      client.valid?
    end

    it { expect(client.valid?).to be_falsey }
    it { expect(client.errors[:rejected_note]).to include("can't be blank") }
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

  context 'exited from ngo should not contain blank data for exit info' do
    let!(:admin){ create(:user, :admin) }
    let!(:valid_client){ create(:client, exit_date: '2017-07-21', exit_note: 'testing', status: 'Exited - Dead') }

    before do
      valid_client.exit_date = ''
      valid_client.exit_note = ''
      valid_client.valid?
    end

    it { expect(valid_client.valid?).to be_falsey }
    it { expect(valid_client.errors.full_messages.first).to include("can't be blank") }
  end
end
