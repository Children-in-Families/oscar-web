describe CaseStatistic, 'statistic data' do
  let!(:ec_client){ create(:client) }
  let!(:fc_client){ create(:client) }
  let!(:kc_client){ create(:client) }
  let!(:ec_case){ create(:case, case_type: 'EC', client: ec_client, created_at: 3.months.ago) }
  let!(:fc_case){ create(:case, case_type: 'FC', client: fc_client, created_at: 2.months.ago) }
  let!(:kc_case){ create(:case, case_type: 'KC', client: kc_client, created_at: 1.month.ago) }

  it 'returns current active cases of clients with single case' do
    data = [
              {:name=>"Active EC", :data=>{3.months.ago.strftime('%B %Y')=>1}},
              {:name=>"Active FC", :data=>{2.months.ago.strftime('%B %Y')=>1}},
              {:name=>"Active KC", :data=>{1.month.ago.strftime('%B %Y')=>1}}
            ]
    expect(CaseStatistic::statistic_data).to eq(data)
  end

  it 'returns current active cases of clients with multiple cases' do
    FactoryGirl.create(:case, case_type: 'FC', client: ec_client, created_at: 2.months.ago)
    data = [
              {:name=>"Active FC", :data=>{2.months.ago.strftime('%B %Y')=>2}},
              {:name=>"Active KC", :data=>{1.month.ago.strftime('%B %Y')=>1}}
            ]
    expect(CaseStatistic::statistic_data).to eq(data)
  end
end
