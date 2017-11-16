describe ActiveEnrollmentStatistic, 'statistic data' do
  let!(:client_1){ create(:client) }
  let!(:client_2){ create(:client) }
  let!(:client_3){ create(:client) }
  let!(:client_4){ create(:client) }
  let!(:client_5){ create(:client) }
  let!(:client_6){ create(:client) }

  let!(:program_1){ create(:program_stream, name: 'PA') }
  let!(:program_2){ create(:program_stream, name: 'PB') }
  let!(:program_3){ create(:program_stream, name: 'PC') }

  let!(:client_enrollment_1){ create(:client_enrollment, client: client_1, program_stream: program_1, enrollment_date: 3.months.ago) }
  let!(:client_enrollment_2){ create(:client_enrollment, client: client_2, program_stream: program_2, enrollment_date: 2.months.ago) }
  let!(:client_enrollment_3){ create(:client_enrollment, client: client_3, program_stream: program_3, enrollment_date: 1.months.ago) }

  let!(:client_enrollment_4){ create(:client_enrollment, client: client_4, program_stream: program_1, enrollment_date: 3.months.ago) }
  let!(:client_enrollment_5){ create(:client_enrollment, client: client_5, program_stream: program_2, enrollment_date: 2.months.ago) }
  let!(:client_enrollment_6){ create(:client_enrollment, client: client_6, program_stream: program_3, enrollment_date: 1.months.ago) }

  it 'returns current active cases of clients with single case' do
    data = [[3.months.ago.strftime("%b-%y"), 2.months.ago.strftime("%b-%y"), 1.month.ago.strftime("%b-%y")], [{:name=>"PA", :data=>[2, nil, nil]}, {:name=>"PB", :data=>[nil, 2, nil]}, {:name=>"PC", :data=>[nil, nil, 2]}]]
    statistic = ActiveEnrollmentStatistic.new(Client.all)
    expect(statistic.statistic_data).to eq(data)
  end

  it 'returns current active cases of clients with multiple cases' do
    FactoryGirl.create(:leave_program, client_enrollment: client_enrollment_1, program_stream: program_1)
    FactoryGirl.create(:leave_program, client_enrollment: client_enrollment_4, program_stream: program_1)
    data = [[2.months.ago.strftime("%b-%y"), 1.months.ago.strftime("%b-%y")], [{:name=>"PB", :data=>[2, nil]}, {:name=>"PC", :data=>[nil, 2]}]]
    statistic = ActiveEnrollmentStatistic.new(Client.all)
    expect(statistic.statistic_data).to eq(data)
  end
end
