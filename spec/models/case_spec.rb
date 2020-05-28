describe Case do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  describe Case, 'associations' do
    it { is_expected.to belong_to(:family) }
    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:partner) }
    it { is_expected.to belong_to(:province) }

    it { is_expected.to have_many(:case_contracts) }
    it { is_expected.to have_many(:quarterly_reports) }
  end

  describe Case, 'validations' do
    let!(:ec_family){ create(:family) }
    let!(:fc_family){ create(:family) }
    let!(:kc_family){ create(:family) }
    let!(:client){ create(:client) }

    context 'case_type' do
      subject{ Case.new(client: client, family: fc_family, start_date: Date.today) }
      it { is_expected.to validate_presence_of(:case_type) }
    end

    context 'family' do
      subject{ Case.new(client: client, start_date: Date.today, case_type: 'FC') }
      it { is_expected.to validate_presence_of(:family) }
    end

    context 'if active' do
      subject{ Case.new(case_type: 'FC', client: client, family: fc_family) }
      before { subject.exited = true }
      it { is_expected.to validate_presence_of(:exit_date) }
      it { is_expected.to validate_presence_of(:exit_note) }
    end

    context 'if inactive' do
      subject{ Case.new(case_type: 'FC', client: client, family: fc_family) }
      before { subject.exited = false }
      it { is_expected.not_to validate_presence_of(:exit_date) }
      it { is_expected.not_to validate_presence_of(:exit_note) }
    end

    context 'if not EC' do
      subject{ Case.new(case_type: 'FC', client: client, start_date: Date.today) }
      before do
        subject.case_type = 'FC'
        subject.family = fc_family
      end
      it { is_expected.to validate_presence_of(:family) }
    end

    context 'if EC' do
      subject{ Case.new(case_type: 'EC', client: client, start_date: Date.today) }
      before do
        subject.case_type = 'EC'
        subject.family = ec_family
      end
      it { is_expected.not_to validate_presence_of(:family) }
    end
  end

  describe Case, 'scopes' do
    let!(:client_1){ create(:client) }
    let!(:emergency){ create(:case, case_type: 'EC') }
    let!(:kinship){ create(:case, :inactive, case_type: 'KC', client: client_1) }
    let!(:foster){ create(:case, case_type: 'FC') }
    let!(:referred) { create(:case, case_type: 'Referred') }

    context 'exclude_referred' do
      it 'should include emergency foster and kinship' do
        expect(Case.exclude_referred).to include(emergency, kinship, foster)
      end
      it 'should not include referred' do
        expect(Case.exclude_referred).not_to include(referred)
      end
    end

    context 'emergencies' do
      let!(:emergencies){ Case.emergencies }
      subject{ emergencies }
      it 'should have emergency' do
        is_expected.to include(emergency)
      end
    end

    context 'non_emergency' do
      let!(:non_emergencies){ Case.non_emergency }
      subject{ non_emergencies }
      it 'should not have emergency' do
        is_expected.not_to include(emergency)
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
        expect([referred, foster, kinship, emergency])
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
    let!(:client_1){ create(:client) }
    let!(:client_2){ create(:client) }
    let!(:client_3){ create(:client) }
    let!(:emergency){ create(:case, case_type: 'EC') }
    let!(:kinship){ create(:case, case_type: 'KC') }
    let!(:foster){ create(:case, case_type: 'FC') }
    let!(:latest_emergency){ create(:case, case_type: 'EC', client: client_1) }
    let!(:latest_kinship){ create(:case, case_type: 'KC', client: client_2) }
    let!(:latest_foster){ create(:case, case_type: 'FC', client: client_3) }

    context 'latest emergency' do
      subject{ Case.latest_emergency }
      it 'should return latest emergency' do
        expect(latest_emergency)
      end
      it 'should not return not latest emergency' do
        expect(is_expected).not_to eq(emergency)
      end
    end

    context 'latest kinship' do
      subject{ Case.latest_kinship }
      it 'should return latest kinship' do
        expect(latest_kinship)
      end
      it 'should not return not latest kinship' do
        expect(is_expected).not_to eq(kinship)
      end
    end

    context 'latest foster' do
      subject{ Case.latest_foster }
      it 'should return latest foster' do
        expect(latest_foster)
      end
      it 'should not return not latest foster' do
        expect(is_expected).not_to eq(foster)
      end
    end

    context 'latest active' do
      let!(:active_case){create(:case, exited: false)}
      let!(:last_active_case){create(:case, exited: false)}
      let!(:inactive_case){create(:case, :inactive)}
      subject { Case.current }
      it 'should return latest active' do
        expect(last_active_case)
      end
      it 'should not return not latest active' do
        expect(is_expected).not_to eq(active_case)
      end
      it 'should not return inactive' do
        expect(is_expected).not_to eq(inactive_case)
      end
    end
  end

  describe Case, 'callbacks' do
    let!(:ec_client){ create(:client) }
    let!(:kc_client){ create(:client) }
    let!(:fc_client){ create(:client) }
    let!(:ec_family){ create(:family, :emergency) }
    let!(:kc_family){ create(:family, :kinship) }
    let!(:fc_family){ create(:family, :foster) }
    let!(:exit_emergency){ create(:case, case_type: 'EC', client: ec_client, family: ec_family, exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph) }
    let!(:emergency){ create(:case, case_type: 'EC', client: ec_client, family: ec_family) }
    let!(:kinship){ create(:case, case_type: 'KC', client: kc_client, family: kc_family) }
    let!(:foster){ create(:case, case_type: 'FC', client: fc_client, family: fc_family) }

    context 'update client status' do
      before do
        ec_client.reload
        kc_client.reload
        fc_client.reload
      end

      context 'when client is not active in any programs' do
        context 'when save case which is just exited' do
          it 'should update status to Accepted' do
            emergency.update(exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph)
            foster.update(exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph)
            kinship.update(exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph)
            ec_client.update(status: "Accepted")
            fc_client.update(status: "Accepted")
            kc_client.update(status: "Accepted")

            ec_client.reload
            fc_client.reload
            kc_client.reload

            expect(ec_client.status).to eq('Accepted')
            expect(fc_client.status).to eq('Accepted')
            expect(kc_client.status).to eq('Accepted')
          end
        end

        context 'when save existing exited case' do
          it 'client status is not changed' do
            ec_client.update(status: "Active")
            expect(ec_client.status).to eq('Active')
            exit_emergency.update(exit_note: FFaker::Lorem.paragraph)
            ec_client.reload
            expect(ec_client.status).to eq('Active')
          end
        end

        it 'should update status to Accepted' do
          kc_client.update(status: "Accepted")
          kinship.update(exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph)
          kc_client.reload
          expect(kc_client.status).to eq('Accepted')
        end

        it 'should update status to Active' do
          kc_client.update(status: "Active")
          expect(kc_client.status).to eq('Active')
        end

        it 'should update kc client code from blank to 2000' do
          kc_client.update(code: "2000")
          expect(kc_client.code).to eq '2000'
        end

        it 'should update status to Active' do
          fc_client.update(status: 'Active')
          expect(fc_client.status).to eq('Active')
        end

        it 'should update fc client code from blank to 1000' do
          fc_client.update(code: '1000')
          expect(fc_client.code).to eq '1000'
        end
      end
      context 'when client is active in any programs' do
        let!(:client_enrollment){ create(:client_enrollment, client: ec_client) }
        context 'when save case which is just exited' do
          it 'should update status to Active' do
            ec_client.update(status: "Active")
            expect(ec_client.status).to eq('Active')
            emergency.update(exited: true, exit_date: Time.now, exit_note: FFaker::Lorem.paragraph)
            ec_client.reload
            expect(ec_client.status).to eq('Active')
          end
        end
        context 'when save existing exited case' do
          it 'client status is not changed' do
            ec_client.update(status: "Active")
            expect(ec_client.status).to eq('Active')
            exit_emergency.update(exit_note: FFaker::Lorem.paragraph)
            ec_client.reload
            expect(ec_client.status).to eq('Active')
          end
        end
      end
    end

    xcontext 'after_save' do
      before do
        ClientHistory.destroy_all
      end


      context 'create_client_history' do
        it 'should have maybe some client histories, one case client history, and one client family history' do
          client  = FactoryGirl.create(:client, given_name: 'AAAA')
          family  = FactoryGirl.create(:family, :emergency, name: 'AAAA')
          ec_case = FactoryGirl.create(:case, client: client, family: family)

          expect(ClientHistory.where('object.family_ids' => family.id).count).to eq(0)
          expect(ClientHistory.where('object.family_ids' => family.id)&.first&.client_family_histories&.count)&.to eq(nil)
          expect(ClientHistory.where('object.case_ids' => ec_case.id).count).to eq(0)
          expect(ClientHistory.where('object.case_ids' => ec_case.id)&.first&.case_client_histories&.count)&.to eq(nil)
        end
      end
    end


    context 'before create' do
      it 'add_family_children' do
        expect(kc_family.children).to include(kc_client.id)
      end
    end
  end
end