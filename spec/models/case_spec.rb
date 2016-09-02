describe Case, 'associations' do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:family) }
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:partner) }
  it { is_expected.to belong_to(:province) }

  it { is_expected.to have_many(:case_contracts) }
  it { is_expected.to have_many(:quarterly_reports) }
end

describe Case, 'validations' do
  subject{ Case.new(case_type: 'FC') }

  it { is_expected.to validate_presence_of(:case_type) }
  it { is_expected.to validate_presence_of(:family) }
  context 'if active' do
    before { subject.exited = true }
    it { is_expected.to validate_presence_of(:exit_date) }
    it { is_expected.to validate_presence_of(:exit_note) }
  end

  context 'if inactive' do
    before { subject.exited = false }
    it { is_expected.not_to validate_presence_of(:exit_date) }
    it { is_expected.not_to validate_presence_of(:exit_note) }
  end

  context 'if not EC' do
    before { subject.case_type = ['KC', 'FC'].sample }
    it { is_expected.to validate_presence_of(:family) }
  end

  context 'if EC' do
    before { subject.case_type = 'EC' }
    it { is_expected.not_to validate_presence_of(:family) }
  end

end

describe Case, 'scopes' do
  let!(:emergency){ create(:case, case_type: 'EC') }
  let!(:kinship){ create(:case, :inactive, case_type: 'KC') }
  let!(:foster){ create(:case, case_type: 'FC') }

  context 'emergencies' do
    let!(:emergencies){ Case.emergencies }
    subject{ emergencies }
    it 'should have emergency' do
      is_expected.to include(emergency)
    end
    it 'should not have kinship or foster' do
      is_expected.not_to include(kinship)
      is_expected.not_to include(foster)
    end
  end

  context 'non_emergency' do
    let!(:non_emergencies){ Case.non_emergency }
    subject{ non_emergencies }
    it 'should not have emergency' do
      is_expected.not_to include(emergency)
    end
    it 'should have kinship or foster' do
      is_expected.to include(kinship)
      is_expected.to include(foster)
    end
  end

  context 'kinships' do
    let!(:kinships){ Case.kinships }
    subject{ kinships }
    it 'should have kinship' do
      is_expected.to include(kinship)
    end
    it 'should not have emergency or foster' do
      is_expected.not_to include(emergency)
      is_expected.not_to include(foster)
    end
  end

  context 'foster' do
    let!(:fosters){ Case.fosters }
    subject{ fosters }
    it 'should have foster' do
      is_expected.to include(foster)
    end
    it 'should not have emergency or kinship' do
      is_expected.not_to include(emergency)
      is_expected.not_to include(kinship)
    end
  end

  context 'most recents' do
    let!(:recents){ Case.most_recents }
    subject{ recents }
    it 'should have correct order' do
      is_expected.to eq([foster, kinship, emergency])
    end
  end

  context 'active' do
    let!(:actives){ Case.active }
    subject{ actives }
    it 'should have exited eq false' do
      is_expected.to include(emergency)
      is_expected.to include(foster)
    end
    it 'should have exited eq true' do
      is_expected.not_to include(kinship)
    end
  end

  context 'inactive' do
    let!(:inactives){ Case.inactive }
    subject{ inactives }
    it 'should have exited eq false' do
      is_expected.not_to include(emergency)
      is_expected.not_to include(foster)
    end
    it 'should have exited eq true' do
      is_expected.to include(kinship)
    end
  end
end

describe Case, 'methods' do
  let!(:client){ create(:client, state: 'accepted') }
  let!(:emergency){ create(:case, case_type: 'EC') }
  let!(:kinship){ create(:case, case_type: 'KC') }
  let!(:foster){ create(:case, case_type: 'FC') }
  let!(:latest_emergency){ create(:case, case_type: 'EC', client: client) }
  let!(:latest_kinship){ create(:case, case_type: 'KC', client: client) }
  let!(:latest_foster){ create(:case, case_type: 'FC') }

  context 'most current?' do
    it { expect(latest_kinship.most_current?).to be_truthy }
    it { expect(latest_emergency.most_current?).to be_falsey }
  end

  context 'latest emergency' do
    subject{ Case.latest_emergency }
    it 'should return latest emergency' do
      is_expected.to eq(latest_emergency)
    end
    it 'should not return not latest emergency' do
      is_expected.not_to eq(emergency)
    end
  end

  context 'latest kinship' do
    subject{ Case.latest_kinship }
    it 'should return latest kinship' do
      is_expected.to eq(latest_kinship)
    end
    it 'should not return not latest kinship' do
      is_expected.not_to eq(kinship)
    end
  end

  context 'latest foster' do
    subject{ Case.latest_foster }
    it 'should return latest foster' do
      is_expected.to eq(latest_foster)
    end
    it 'should not return not latest foster' do
      is_expected.not_to eq(foster)
    end
  end

  context 'latest active' do
    let!(:active_case){create(:case, exited: false)}
    let!(:last_active_case){create(:case, exited: false)}
    let!(:inactive_case){create(:case, :inactive)}
    subject { Case.current }
    it 'should return latest active' do
      is_expected.to eq(last_active_case)
    end
    it 'should not return not latest active' do
      is_expected.not_to eq(active_case)
    end
    it 'should not return inactive' do
      is_expected.not_to eq(inactive_case)
    end
  end
end

describe Case, 'callbacks' do
  let!(:ec_client){ create(:client) }
  let!(:kc_client){ create(:client) }
  let!(:fc_client){ create(:client) }
  let!(:other_emergency){ create(:case, case_type: 'EC', client: kc_client) }
  let!(:emergency){ create(:case, case_type: 'EC', client: ec_client) }
  let!(:kinship){ create(:case, case_type: 'KC', client: kc_client) }
  let!(:foster){ create(:case, case_type: 'FC', client: fc_client) }

  context 'update client status' do
    before do
      ec_client.reload
      kc_client.reload
      fc_client.reload
    end

    it 'should update status to Active EC' do
      kinship.update(exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph)

      kc_client.reload

      expect(kc_client.status).to eq('Active EC')
      expect(ec_client.reload.status).to eq('Active EC')
    end

    it 'should update status to Active KC' do
      expect(kc_client.status).to eq('Active KC')
    end

    it 'should update kc client code from blank to 2000' do
      expect(kc_client.code).to eq '2000'
    end

    it 'should update status to Active FC' do
      expect(fc_client.status).to eq('Active FC')
    end

    it 'should update fc client code from blank to 1000' do
      expect(fc_client.code).to eq '1000'
    end

    it 'should update status to Referred' do
      emergency.update(exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph)
      foster.update(exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph)

      ec_client.reload
      fc_client.reload

      expect(ec_client.status).to eq('Referred')
      expect(fc_client.status).to eq('Referred')
    end

  end

  context 'update cases to exited from cif' do
    let!(:fc_client){ create(:client) }
    let!(:kinship){ create(:case, case_type: 'KC', client: fc_client) }
    let!(:foster){ create(:case, case_type: 'FC', client: fc_client) }
    before do
      foster.update(
        exited_from_cif: true,
        exit_date: Time.now,
        exit_note: FFaker::Lorem.paragraph
      )
      kinship.reload
    end
    it 'should update all cases' do
      expect(kinship.exited_from_cif).to be_truthy
      expect(kinship.exited).to be_truthy
      expect(kinship.exit_date).to eq(foster.exit_date)
      expect(kinship.exit_note).to eq(foster.exit_note)
    end
  end

end
