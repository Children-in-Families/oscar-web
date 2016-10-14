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

  it 'returns current active cases of clients with single case' do
    data = [
      ["Jul-16", "Aug-16", "Sep-16"],[{:name=>"Active EC", :data=>[2, nil, nil]},{:name=>"Active FC", :data=>[nil, 2, nil]},{:name=>"Active KC", :data=>[nil, nil, 2]}]
    ]
    
    statistic = CaseStatistic.new(Client.all)
    expect(statistic.statistic_data).to eq(data)
  end

  it 'returns current active cases of clients with multiple cases' do
    FactoryGirl.create(:case, case_type: 'FC', client: ec_client, start_date: 2.months.ago)
    data = [
              ["Aug-16", "Sep-16"],[{:name=>"Active FC", :data=>[3, nil]},{:name=>"Active KC", :data=>[nil, 2]}]
            ]
    expect(CaseStatistic.new(Client.all).statistic_data).to eq(data)
  end

end

