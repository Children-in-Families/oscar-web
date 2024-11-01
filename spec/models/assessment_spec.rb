describe Assessment do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return('abcd')
  end

  describe Assessment, 'associations' do
    it { is_expected.to belong_to(:client).counter_cache(true) }
    it { is_expected.to belong_to(:family).counter_cache(true) }
    it { is_expected.to have_many(:assessment_domains).dependent(:destroy) }
    it { is_expected.to have_many(:domains).through(:assessment_domains) }
    it { is_expected.to have_many(:case_notes).dependent(:destroy) }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to have_many(:goals).dependent(:destroy) }

    it { is_expected.to accept_nested_attributes_for(:assessment_domains) }
  end

  describe Assessment, 'validations' do
    let!(:client) { create(:client) }
    let!(:assessment) { create(:assessment, created_at: Date.today - 7.month, client: client) }

    xcontext 'update?' do
      let!(:last_assessment) { create(:assessment, client: client) }

      it 'should updatable if latest' do
        expect(last_assessment).to be_valid
      end
      it 'should not update if not latest' do
        expect(assessment).not_to be_valid
      end
      it 'should have message Assessment cannot be updated' do
        assessment.save
        expect(assessment.errors.full_messages).to include('Assessment cannot be updated')
      end
    end

    context 'create?' do
      let!(:other_client) { create(:client) }
      let!(:other_assessment) { create(:assessment, client: other_client) }
      let!(:valid_assessment) { Assessment.new(client: client, created_at: Time.now - 3.months) }
      let!(:valid_assessment_1) { Assessment.new(client: client) }
      let!(:valid_third_assessment) { Assessment.new(client: client) }
      let!(:invalid_assessment) { Assessment.new(client: other_client) }

      it { expect(valid_assessment).to be_valid }
      it { expect(invalid_assessment).not_to be_invalid }
      it { expect(valid_assessment_1).to be_valid }

      it 'should NOT have message Assessment cannot be created due to either frequency period or previous assessment status' do
        valid_assessment_1.save
        valid_third_assessment.save

        expect(valid_assessment_1.errors.full_messages).to be_empty
        expect(valid_third_assessment.errors.full_messages).to be_empty
      end

      it 'should have message Assessment cannot be created due to either frequency period or previous assessment status' do
        invalid_assessment.save
        expect(invalid_assessment.errors.full_messages).to eq([])
      end

      # it { is_expected.to validate_presence_of(:client) }
    end
  end

  describe Assessment, 'methods' do
    let(:last_assessment_date) { Time.now - 3.months - 1.day }
    let!(:client) { create(:client) }
    let!(:assessment) { create(:assessment, created_at: last_assessment_date, client: client) }
    let!(:domain) { create(:domain) }
    let!(:other_domain) { create(:domain) }
    let!(:assessment_domain) { create(:assessment_domain, assessment: assessment, domain: domain) }

    context '#latest_record?' do
      let!(:last_assessment) { create(:assessment, created_at: Time.now, client: client) }
      it { expect(last_assessment.latest_record?).to be_truthy }
      it { expect(assessment.latest_record?).to be_falsey }
    end

    context '#initial?' do
      before { Setting.first.update(enable_custom_assessment: true) }
      let!(:last_assessment) { create(:assessment, created_at: Time.now, client: client) }
      let!(:custom_assessment_1) { create(:assessment, :custom, client: client, created_at: last_assessment_date) }
      let!(:custom_assessment_2) { create(:assessment, :custom, client: client) }
      it 'detault' do
        expect(assessment.initial?).to be_truthy
        expect(last_assessment.initial?).to be_falsey
      end
      xit 'custom' do
        expect(custom_assessment_1.initial?).to be_truthy
        expect(custom_assessment_2.initial?).to be_falsey
      end
    end

    xcontext '#populate_notes(default)' do
      before do
        assessment.populate_notes(assessment.default.to_s)
      end
      it 'should build assessment domains' do
        expect(assessment.assessment_domains.size).not_to eq(0)
      end
      it 'should build assessment domains with existing domain' do
        expect(assessment.assessment_domains.map(&:domain)).to include(domain)
      end
    end

    context '#latest_record' do
      let!(:last_assessment) { create(:assessment, client: client) }
      subject { Assessment.latest_record }

      it 'should return latest record' do
        is_expected.to eq(last_assessment)
      end

      it 'should not return not latest record' do
        is_expected.not_to eq(assessment)
      end
    end

    context '#basic_info' do
      it 'should return domain infomation string' do
        expect(assessment.basic_info).to eq "#{last_assessment_date.to_date} => #{domain.name}: #{assessment_domain.score}"
      end
    end

    context '#assessment_domains_score' do
      it 'should return domain score infomation string' do
        expect(assessment.assessment_domains_score).to eq "#{domain.name}: #{assessment_domain.score}"
      end
    end

    context '#assessment_domains_in_order' do
      let!(:other_assessment_domain) { create(:assessment_domain, assessment: assessment, domain: other_domain) }
      it 'should return assessment domains in order' do
        expect(assessment.assessment_domains_in_order).to eq([assessment_domain, other_assessment_domain])
      end
    end

    context '#index_of' do
      let!(:client) { create(:client) }
      let!(:assessment) { create(:assessment, client: client) }

      it 'return index of assessment is 0' do
        expect(assessment.index_of).to eq(0)
      end
    end
  end

  describe Assessment, 'scopes' do
    let!(:assessment) { create(:assessment) }
    let!(:other_assessment) { create(:assessment) }
    let!(:order) { [other_assessment, assessment] }
    context '.most_recents' do
      xit 'should have correct order' do
        expect(Assessment.most_recents).to eq(order)
      end
    end

    context '.defaults' do
      let!(:default_assessment) { create(:assessment, default: true) }
      it 'should return default assessments' do
        expect(Assessment.defaults).to include(default_assessment)
      end
    end

    context '.customs' do
      before { Setting.first.update(enable_custom_assessment: true) }
      let!(:custom_assessment) { create(:assessment, default: false) }
      it 'should return default assessments' do
        expect(Assessment.customs).to include(custom_assessment)
      end
    end
  end

  describe Assessment, 'callbacks' do
    context 'set_previous_score' do
      before { Setting.first.update(enable_custom_assessment: true) }
      let!(:client) { create(:client) }
      let!(:domain) { create(:domain) }
      let!(:assessment_1) { create(:assessment, created_at: Time.now - 3.months - 1.day, client: client) }
      let!(:assessment_domain) { create(:assessment_domain, assessment: assessment_1, domain: domain) }
      let!(:custom_assessment_1) { create(:assessment, :custom, created_at: Time.now - 3.months - 1.day, client: client) }
      let!(:custom_assessment_domain) { create(:assessment_domain, assessment: custom_assessment_1, domain: domain) }
      let!(:assessment_2) { build(:assessment, client: client) }
      let!(:custom_assessment_2) { build(:assessment, :custom, client: client) }

      before do
        assessment_domain_attr = { domain: domain, score: rand(4) + 1, reason: FFaker::Lorem.paragraph, goal: FFaker::Lorem.paragraph }
        assessment_2.assessment_domains.build(assessment_domain_attr)
        assessment_2.save
        custom_assessment_2.assessment_domains.build(assessment_domain_attr)
        custom_assessment_2.save
      end

      it 'should eq lastet assessment score' do
        previous_score = assessment_2.assessment_domains.find_by(domain: domain).previous_score
        expect(previous_score).to eq(assessment_domain.score)
      end

      it 'should eq lastet custom assessment score' do
        previous_score = custom_assessment_2.assessment_domains.find_by(domain: domain).previous_score
        expect(previous_score).to eq(custom_assessment_domain.score)
      end
    end

    context 'allow_create' do
      let!(:client) { create(:client, :accepted) }
      xcontext 'frequency period' do
        let!(:assessment) { create(:assessment, client: client, created_at: 2.month.ago.to_date) }
        it 'return error message' do
          second_assessment = Assessment.create(client: client)
          expect(second_assessment.errors.full_messages).to include('Assessment cannot be created due to either frequency period or previous assessment status')
        end
        it 'not return error message' do
          assessment.update(created_at: 3.months.ago)
          second_assessment = Assessment.create(client: client)
          expect(second_assessment.errors.full_messages).not_to include('Assessment cannot be created due to either frequency period or previous assessment status')
        end
      end

      context 'previous assessment status' do
        context 'not completed' do
          let!(:assessment) { create(:assessment, :with_assessment_domain, client: client, created_at: 3.months.ago) }
          it 'return error message' do
            assessment_1 = Assessment.create(client: client)
            expect(assessment_1.errors.full_messages).to include('Assessment cannot be created due to either frequency period or previous assessment status')
          end
        end
        context 'completed' do
          let!(:assessment) { create(:assessment, client: client, created_at: 3.months.ago) }
          it 'not return error message' do
            assessment_1 = Assessment.create(client: client)
            expect(assessment_1.errors.full_messages).not_to include('Assessment cannot be created due to either frequency period or previous assessment status')
          end
        end
      end
    end

    context '#must_be_enable' do
      before do
        Setting.first.update(enable_custom_assessment: false)
      end
      context 'new record' do
        context 'default csi' do
          let(:default_csi) { build(:assessment) }
          it 'should not return error message' do
            expect(default_csi).to be_valid
            expect(default_csi.errors.full_messages).not_to include('Assessment tool must be enable in setting')
          end
        end

        context 'custom csi' do
          let(:custom_csi) { build(:assessment, default: false) }
          it 'should return error message' do
            expect(custom_csi).to be_invalid
            expect(custom_csi.errors.full_messages).to include('Assessment tool must be enable in setting')
          end
        end
      end

      context 'persisted record' do
        let!(:default_csi) { create(:assessment) }
        it 'invalid' do
          default_csi.update(default: false)
          expect(default_csi).to be_invalid
          expect(default_csi.errors.full_messages).to include('Assessment tool must be enable in setting')
        end
      end
    end

    context 'eligible_client_age' do
      let!(:client) { create(:client, date_of_birth: 18.years.ago.to_date) }
      let!(:client_1) { create(:client, date_of_birth: 15.years.ago.to_date) }
      let!(:existing_assessment) { create(:assessment, client: client_1) }
      before { Setting.first.update(enable_default_assessment: true, custom_age: 15) }

      context 'default csi' do
        it 'return error message if new record' do
          assessment = Assessment.create(client: client)
          expect(assessment.errors.full_messages).to include("Assessment cannot be added due to client's age.")
        end

        it 'not return error message if existing record' do
          client_1.update(date_of_birth: 18.years.ago.to_date)
          existing_assessment.update(client: client_1)
          expect(existing_assessment.errors.full_messages).not_to include("Assessment cannot be added due to client's age.")
        end
      end

      context 'custom csi' do
        xit 'return error message if new record' do
          assessment = Assessment.create(client: client_1, default: false)
          expect(assessment.errors.full_messages).to include("Assessment cannot be added due to client's age.")
        end

        it 'not return error message if existing record' do
          existing_assessment.update(client: client_1)
          expect(existing_assessment.errors.full_messages).not_to include("Assessment cannot be added due to client's age.")
        end
      end
    end
  end

  describe Assessment, 'CONSTANTS' do
    context 'DUE_STATES' do
      it { expect(Assessment::DUE_STATES).to eq(['Due Today', 'Overdue']) }
    end
  end
end
