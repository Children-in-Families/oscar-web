describe Assessment, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to have_many(:assessment_domains) }
  it { is_expected.to have_many(:domains) }
  it { is_expected.to have_many(:case_notes) }

  it { is_expected.to accept_nested_attributes_for(:assessment_domains) }
end

describe Assessment, 'validations' do
  let!(:client){ create(:client) }
  let!(:assessment){ create(:assessment, created_at: Date.today - 7.month, client: client) }

  context 'update?' do
    let!(:last_assessment){ create(:assessment, client: client) }

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
    let!(:other_client){ create(:client) }
    let!(:other_assessment){ create(:assessment, client: other_client) }
    let!(:valid_assessment){ Assessment.new(client: client, created_at: Time.now - 3.months) }
    let!(:valid_assessment_1){ Assessment.new(client: client) }
    let!(:valid_third_assessment){ Assessment.new(client: client) }
    let!(:invalid_assessment){ Assessment.new(client: other_client) }


    it { expect(valid_assessment).to be_valid }
    it { expect(invalid_assessment).not_to be_valid }
    it { expect(valid_assessment_1).to be_valid }

    it 'should NOT have message Assessment cannot be created before 3 months' do
      valid_assessment_1.save
      valid_third_assessment.save

      expect(valid_assessment_1.errors.full_messages).to be_empty
      expect(valid_third_assessment.errors.full_messages).to be_empty
    end

    it 'should have message Assessment cannot be created before 3 months' do
      invalid_assessment.save
      expect(invalid_assessment.errors.full_messages).to include('Assessment cannot be created before 3 months')
    end

    it { is_expected.to validate_presence_of(:client) }
  end
end

describe Assessment, 'methods' do
  let(:last_assessment_date) { Time.now - 3.months - 1.day }
  let!(:client) { create(:client) }
  let!(:assessment) { create(:assessment, created_at: last_assessment_date, client: client) }
  let!(:domain) { create(:domain) }
  let!(:other_domain){ create(:domain) }
  let!(:assessment_domain) { create(:assessment_domain, assessment: assessment, domain: domain) }

  context 'latest record?' do
    let!(:last_assessment){ create(:assessment, created_at: Time.now, client: client) }
    it { expect(last_assessment.latest_record?).to be_truthy }
    it { expect(assessment.latest_record?).to be_falsey }
  end

  context 'initial?' do
    let!(:last_assessment){ create(:assessment, created_at: Time.now, client: client) }
    it { expect(assessment.initial?).to be_truthy }
    it { expect(last_assessment.initial?).to be_falsey }
  end

  context 'populate notes' do
    before do
      assessment.populate_notes
    end
    it 'should build assessment domains' do
      expect(assessment.assessment_domains.size).not_to eq(0)
    end
    it 'should build assessment domains with existing domain' do
      expect(assessment.assessment_domains.map(&:domain)).to include(domain)
    end
  end

  context 'latest record' do
    let!(:last_assessment){ create(:assessment, client: client) }
    subject{ Assessment.latest_record }

    it 'should return latest record' do
      is_expected.to eq(last_assessment)
    end

    it 'should not return not latest record' do
      is_expected.not_to eq(assessment)
    end
  end

  context 'basic info' do
    it 'should return domain infomation string' do
      expect(assessment.basic_info).to eq "#{last_assessment_date.to_date} => #{domain.name}: #{assessment_domain.score}"
    end
  end

  context 'assessment domains score' do
    it 'should return domain score infomation string' do
      expect(assessment.assessment_domains_score).to eq "#{domain.name}: #{assessment_domain.score}"
    end
  end

  context 'assessment domains in order' do
    let!(:other_assessment_domain){ create(:assessment_domain, assessment: assessment, domain: other_domain) }
    it 'should return assessment domains in order' do
      expect(assessment.assessment_domains_in_order).to eq([assessment_domain, other_assessment_domain])
    end
  end
end

describe Assessment, 'scopes' do
  let!(:assessment){ create(:assessment) }
  let!(:other_assessment){ create(:assessment) }
  let!(:order){ [other_assessment, assessment] }
  context 'most_recents' do
    it 'should have correct order' do
      expect(Assessment.most_recents).to eq(order)
    end
  end
end

describe Assessment, 'callbacks' do
  context 'set previous score' do
    let!(:client) { create(:client) }
    let!(:domain) { create(:domain) }
    let!(:assessment) { create(:assessment, created_at: Time.now - 3.months - 1.day, client: client) }
    let!(:assessment_domain) { create(:assessment_domain, assessment: assessment, domain: domain) }
    let!(:last_assessment) { client.assessments.new }

    before do
      last_assessment.assessment_domains.build(domain: domain, score: rand(4)+1, reason: FFaker::Lorem.paragraph, goal: FFaker::Lorem.paragraph)
      last_assessment.save
    end

    it "should eq lastet assessment score" do
      previous_score = last_assessment.assessment_domains.find_by(domain: domain).previous_score
      expect(previous_score).to eq(assessment_domain.score)
    end
  end

  context 'must_be_min_assessment_period' do
    let!(:client) { create(:client) }
    let!(:setting) { create(:setting, :monthly_assessment, min_assessment: 4) }
    let!(:assessment) { create(:assessment, client: client, created_at: 3.month.ago.to_date) }

    it "should be return error message" do
      second_assessment = Assessment.create(client: client)
      expect(second_assessment.errors.full_messages).to include('Assessment cannot be created before 4 months')
    end
  end

  context 'must_be_enable_assessment' do
    let!(:client) { create(:client) }
    let!(:setting) { create(:setting, disable_assessment: true) }

    it 'should return error message' do
      assessment = Assessment.create(client: client)
      expect(assessment.errors.full_messages).to include('Assessment tool must be enable in setting')
    end
  end
end

describe Assessment, 'CONSTANTS' do
  context 'DUE_STATES' do
    it { expect(Assessment::DUE_STATES).to eq(['Due Today', 'Overdue']) }
  end
end
