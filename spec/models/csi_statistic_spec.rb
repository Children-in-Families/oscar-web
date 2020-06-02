describe CsiStatistic do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end

  describe CsiStatistic, 'statistic data' do
    let!(:user) { create(:user) }
    let!(:client) { create(:client, :accepted, users: [user]) }
    let!(:domain) { create(:domain, name: '1A') }

    let!(:assessment){ create(:assessment, client: client, created_at: 7.months.ago) }
    let!(:other_assessment){ create(:assessment, client: client, created_at: Date.today) }

    let!(:assessment_domain){ create(:assessment_domain, assessment: assessment, domain: domain, note: 'test', score: 4, created_at: 7.months.ago)}
    let!(:other_assessment_domain){ create(:assessment_domain, assessment: other_assessment, domain: domain, note: 'test', score: 3, created_at: Date.today)}

    it 'returns average domain score without filter' do
      data = [["Assessment (1)", "Assessment (2)"], [{:name=>"1A", :data=>[4.0, 3.0]}]]

      statistic = CsiStatistic.new(Client.all)
      expect(statistic.assessment_domain_score).to eq(data)
    end
  end
end