describe CaseStatistic, 'statistic data' do
  let!(:ec_client){ create(:client) }
  let!(:fc_client){ create(:client) }
  let!(:kc_client){ create(:client) }

  let!(:ec_client2){ create(:client) }
  let!(:fc_client2){ create(:client) }
  let!(:kc_client2){ create(:client) }

  let!(:b_ec_case){ create(:case, case_type: 'EC', client: ec_client2, start_date: 3.years.ago) }
  let!(:b_fc_case){ create(:case, case_type: 'FC', client: fc_client2, start_date: 2.years.ago) }
  let!(:b_kc_case){ create(:case, case_type: 'KC', client: kc_client2, start_date: 2.year.ago) }

  let!(:ec_case){ create(:case, case_type: 'EC', client: ec_client, start_date: 3.months.ago) }
  let!(:fc_case){ create(:case, case_type: 'FC', client: fc_client, start_date: 2.months.ago) }
  let!(:kc_case){ create(:case, case_type: 'KC', client: kc_client, start_date: 1.month.ago) }

  it 'returns current active cases of clients with single case without filter' do
    data = [
              {:name=>"Active EC", :data=>{3.months.ago.strftime('%B %Y')=>2}},
              {:name=>"Active FC", :data=>{2.months.ago.strftime('%B %Y')=>2}},
              {:name=>"Active KC", :data=>{1.month.ago.strftime('%B %Y')=>2}}
            ]
    
    statistic = CaseStatistic.new('', '')
    expect(statistic.statistic_data).to eq(data)
  end

  it 'returns current active cases of clients with single case and has filter start date' do
    data = [
              {:name=>"Active FC", :data=>{2.months.ago.strftime('%B %Y')=>2}},
              {:name=>"Active KC", :data=>{1.month.ago.strftime('%B %Y')=>2}}
            ]
    
    statistic = CaseStatistic.new(2.months.ago.to_date.to_s, Date.today.to_s)
    expect(statistic.statistic_data).to eq(data)
  end

  it 'returns current active cases of clients with multiple cases without filter' do
    FactoryGirl.create(:case, case_type: 'FC', client: ec_client, start_date: 2.months.ago)
    data = [
              {:name=>"Active FC", :data=>{2.months.ago.strftime('%B %Y')=>3}},
              {:name=>"Active KC", :data=>{1.month.ago.strftime('%B %Y')=>2}}
            ]
    expect(CaseStatistic.new('', '').statistic_data).to eq(data)
  end

  it 'returns current active cases of clients with multiple cases and has filter start date' do
    FactoryGirl.create(:case, case_type: 'FC', client: ec_client, start_date: 2.months.ago)
    data = [
              {:name=>"Active FC", :data=>{2.months.ago.strftime('%B %Y')=>3}},
              {:name=>"Active KC", :data=>{1.month.ago.strftime('%B %Y')=>2}}
            ]
    statistic = CaseStatistic.new(2.months.ago.to_date.to_s, Date.today.to_s)
    expect(statistic.statistic_data).to eq(data)
  end
end
