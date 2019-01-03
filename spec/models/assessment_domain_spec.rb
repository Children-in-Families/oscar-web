describe AssessmentDomain, 'associations' do
  it { is_expected.to belong_to(:assessment)}
  it { is_expected.to belong_to(:domain)}
  it { is_expected.to have_and_belong_to_many(:progress_notes)}
end

describe AssessmentDomain, 'validations' do
  it { is_expected.to validate_presence_of(:domain) }
end

describe AssessmentDomain, 'class method' do
  let(:domain_1A) { create(:domain, name: '1A', score_1_color: 'danger', score_2_color: 'danger', score_3_color: 'warning') }
  let(:assessment) { create(:assessment) }
  let(:other_assessment) { create(:assessment) }
  let!(:critical_problem) { create(:assessment_domain, assessment: assessment, score: 2, domain: domain_1A) }
  let!(:good) { create(:assessment_domain, assessment: other_assessment, score: 4, domain: domain_1A) }

  context 'domain_color_class' do
    it { expect(assessment.assessment_domains.domain_color_class(domain_1A)).to eq('danger') }
    it { expect(other_assessment.assessment_domains.domain_color_class(domain_1A)).to eq('primary') }
  end
end

describe AssessmentDomain, 'instance method' do
  let!(:domain_1A) { create(:domain, name: '1A', score_1_color: 'danger', score_2_color: 'danger', score_3_color: 'warning', score_1_definition: 'score 1 definition', score_2_definition: 'score 2 definition') }
  let!(:critical_problem) { create(:assessment_domain, score: 1, previous_score: 1) }
  let!(:other_critical_problem) { create(:assessment_domain, previous_score: 1, score: 2, domain: domain_1A) }
  let!(:has_problem) { create(:assessment_domain, score: 2, previous_score: 2) }
  let!(:other_has_problem) { create(:assessment_domain, score: 3, domain: domain_1A) }
  let!(:not_ideal) { create(:assessment_domain, score: 3, previous_score: 3) }
  let!(:good) { create(:assessment_domain, score: 4, previous_score: 4) }


  context '#good?' do
    # it 'should be true when score eq 4' do
    #   Domain.update_all(score_4_color: 'success', score_4_color: 'primary')
    #   expect(good.good?).to be_truthy
    # end

    it 'should be false when score not eq 3' do
      expect(critical_problem.good?).to be_falsey
      expect(other_critical_problem.good?).to be_falsey
      expect(has_problem.good?).to be_falsey
      expect(other_has_problem.good?).to be_falsey
      expect(not_ideal.good?).to be_falsey
    end
  end

  context '#not_ideal?' do
    it 'should be true when score eq 3 and not in domain 1A' do
      expect(not_ideal.not_ideal?).to be_truthy
    end

    it 'should be false when score not eq 3 or in domain 1A' do
      expect(critical_problem.good?).to be_falsey
      expect(other_critical_problem.good?).to be_falsey
      expect(has_problem.good?).to be_falsey
      expect(other_has_problem.good?).to be_falsey
    end
  end

  context '#has_problem?' do
    it 'should be true when score eq 2 and not in domain 1A' do
      expect(has_problem.has_problem?).to be_truthy
    end

    it 'should be true when score eq 3 and in domain 1A' do
      expect(other_has_problem.has_problem?).to be_truthy
    end

    it 'should be false when score not eq 2' do
      expect(critical_problem.has_problem?).to be_falsey
      expect(other_critical_problem.has_problem?).to be_falsey
      expect(not_ideal.has_problem?).to be_falsey
      expect(good.has_problem?).to be_falsey
    end
  end

  context '#critical_problem?' do
    it 'should be true when score eq 1' do
      expect(critical_problem.critical_problem?).to be_truthy
    end

    it 'should be true when score eq 2 and in domain 1A' do
      expect(other_critical_problem.critical_problem?).to be_truthy
    end

    it 'should be false when score not eq 1' do
      expect(has_problem.critical_problem?).to be_falsey
      expect(other_has_problem.critical_problem?).to be_falsey
      expect(not_ideal.critical_problem?).to be_falsey
      expect(good.critical_problem?).to be_falsey
    end
  end

  context '#score_color_class' do
    it { expect(critical_problem.score_color_class).to eq('danger') }
    it { expect(has_problem.score_color_class).to eq('warning') }
    it { expect(not_ideal.score_color_class).to eq('info') }
    # it { expect(good.score_color_class).to eq('primary')}
  end

  context '#previous_score_color_class' do
    it { expect(critical_problem.previous_score_color_class).to eq('danger') }
    it { expect(has_problem.previous_score_color_class).to eq('warning') }
    it { expect(not_ideal.previous_score_color_class).to eq('info') }
    # it { expect(good.previous_score_color_class).to eq('primary')}
  end

  context '#score_definition' do
    it { expect(other_critical_problem.score_definition).to eq('score 2 definition') }
  end

  context '#previous_score_definition' do
    it { expect(other_critical_problem.previous_score_definition).to eq('score 1 definition') }
  end
end

describe AssessmentDomain, 'scopes' do
  let!(:assessment_domain){ create(:assessment_domain, goal: FFaker::Lorem.word) }
  let!(:other_assessment_domain){ create(:assessment_domain, goal: FFaker::Lorem.word) }
  context 'goal like' do
    it 'should include assessment_domain with goal like' do
        expect(AssessmentDomain.goal_like([assessment_domain.goal])).to include(assessment_domain)
    end
    it 'should not include assessment_domain with other goal' do
        expect(AssessmentDomain.goal_like([assessment_domain.goal])).not_to include(other_assessment_domain)
    end
  end
end
