describe Dashboard, 'Method' do
  let!(:client)            { create(:client)  }
  let!(:client_ec)         { create(:client, status: 'Active EC')  }
  let!(:client_fc)         { create(:client, :female, status: 'Active FC')  }
  let!(:client_kc)         { create(:client, :female, status: 'Active KC')  }
  let!(:program_stream)    { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client, status: 'Active') }
  let!(:client_ec_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client_ec, status: 'Active') }
  let!(:client_fc_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client_fc, status: 'Active') }
  let!(:client_kc_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client_kc, status: 'Active') }
  let!(:kc_family)         { create(:family, :kinship) }
  let!(:other_kc_family)   { create(:family, :kinship) }
  let!(:fc_family)         { create(:family, :foster) }
  let!(:othter_fc_family)  { create(:family, :foster) }
  let!(:ec_family)         { create(:family, :emergency, code: rand(1000..2000).to_s) }

  context '#client_program_stream' do
    before do
      @program_stream_report = Dashboard.new(Client.all).client_program_stream.first
    end

    it 'should return attribute size 3' do
      expect(@program_stream_report.to_json).to have_json_size(3)
    end

    it 'includes name attribute' do
      program_stream_report = @program_stream_report.to_json
      expect(program_stream_report).to have_json_path('name')
    end

    it 'includes y attribute' do
      program_stream_report = @program_stream_report.to_json
      expect(program_stream_report).to have_json_path('y')
    end

    it 'includes url attribute' do
      program_stream_report = @program_stream_report.to_json
      expect(program_stream_report).to have_json_path('url')
    end

    it 'should return object not empty' do
      program_stream_report = @program_stream_report
      expect(program_stream_report[:name]).to eq(program_stream.name)
      expect(program_stream_report[:y]).to eq(4)
      expect(program_stream_report[:url]).not_to eq('')
    end

    it 'should return actively enroll in a program' do
      program_stream_report = @program_stream_report
      expect(program_stream_report[:y]).to eq(4)
    end

    it 'should not return empty url of the program' do
      program_stream_report = @program_stream_report
      expect(program_stream_report[:url]).not_to eq('')
    end
  end

  context '#program_stream_report_gender' do
    before do
      @program_stream_report_gender_report = Dashboard.new(Client.all).program_stream_report_gender
    end

    it 'should return client gender statistic size' do
      program_stream_report_gender_report = @program_stream_report_gender_report
      expect(program_stream_report_gender_report.size).to eq(2)
    end

    it 'should return male clients active program count' do
      program_stream_report_gender_report = @program_stream_report_gender_report
      expect(program_stream_report_gender_report.first[:y]).to eq(2)
    end

    it 'should return female clients active program count' do
      program_stream_report_gender_report = @program_stream_report_gender_report
      expect(program_stream_report_gender_report.second[:y]).to eq(2)
    end

    it 'should return male clients active by program' do
      program_stream_report_gender_report = @program_stream_report_gender_report
      expect(program_stream_report_gender_report.first[:active_data].first[:y]).to eq(2)
    end

    it 'should return female clients active by program' do
      program_stream_report_gender_report = @program_stream_report_gender_report
      expect(program_stream_report_gender_report.second[:active_data].first[:y]).to eq(2)
    end
  end

  context '#family_type_statistic' do
    before do
      @family_type_statistic_report = Dashboard.new(Client.all).family_type_statistic
    end

    it 'should return families Foster count' do
      family_type_statistic_report = @family_type_statistic_report
      expect(family_type_statistic_report.first[:y]).to eq(2)
    end

    it 'should return clients Kinship count' do
      family_type_statistic_report = @family_type_statistic_report
      expect(family_type_statistic_report.second[:y]).to eq(2)
    end

    it 'should return clients Emergency count' do
      family_type_statistic_report = @family_type_statistic_report
      expect(family_type_statistic_report.third[:y]).to eq(1)
    end
  end

  context '#family_count' do
    it 'shoud return family count' do
      expect(Dashboard.new(Client.all).family_count).to eq(5)
    end
  end

  context '#foster_count' do
    it 'shoud return family of foster count' do
      expect(Dashboard.new(Client.all).foster_count).to eq(2)
    end
  end

  context '#kinship_count' do
    it 'shoud return family of kinship count' do
      expect(Dashboard.new(Client.all).kinship_count).to eq(2)
    end
  end

  context '#emergency_count' do
    it 'shoud return family of emergency count' do
      expect(Dashboard.new(Client.all).emergency_count).to eq(1)
    end
  end

  context '#referral_source_count' do
    it 'shoud return referral source count' do
      expect(Dashboard.new(Client.all).referral_source_count).to eq(4)
    end
  end

  context '#program_stream_count' do
    it 'shoud return program stream count' do
      expect(Dashboard.new(Client.all).program_stream_count).to eq(1)
    end
  end
end
