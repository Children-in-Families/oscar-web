describe CsiStatistic, 'statistic data' do
  let!(:user) { create(:user) }
  let!(:client) { create(:client, state: 'accepted', user: user) }
  let!(:domain) { create(:domain, name: '1A') }
  
  let!(:assessment){ create(:assessment, client: client, created_at: 7.months.ago) }
  let!(:other_assessment){ create(:assessment, client: client, created_at: Date.today) }

  let!(:assessment_domain){ create(:assessment_domain, assessment: assessment, domain: domain, note: 'test', score: 4, created_at: 7.months.ago)}
  let!(:other_assessment_domain){ create(:assessment_domain, assessment: other_assessment, domain: domain, note: 'test', score: 3, created_at: Date.today)}

  it 'returns average domain score without filter' do
    data = [{:name=>"1A", :data=>{:"Assessment (1)"=>4.0,
              :"Assessment (2)"=>3.0}}]
    
    statistic = CsiStatistic.new('', '')
    expect(statistic.assessment_domain_score).to eq(data)
  end

  it 'returns average domain score with filter date' do
    data = [{:name=>"1A", :data=>{:"Assessment (1)"=>4.0, 
              :"Assessment (2)"=>3.0}}]
    
    statistic = CsiStatistic.new(7.months.ago.to_date.to_s, 5.month.ago.to_date.to_s)
    expect(statistic.assessment_domain_score).to eq(data)
  end
end
