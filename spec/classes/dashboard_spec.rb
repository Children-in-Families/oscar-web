describe Dashboard, 'Method' do
  let!(:client)            { create(:client)  }
  let!(:able_client)       { create(:client, able_state: 'Accepted')  }
  let!(:client_ec)         { create(:client, gender: 'male', status: 'Active EC')  }
  let!(:client_fc)         { create(:client, gender: 'female', status: 'Active FC')  }
  let!(:client_kc)         { create(:client, gender: 'female', status: 'Active KC')  }
  let!(:program_stream)    { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client, status: 'Active') }
  let!(:kc_family)         { create(:family, :kinship) }
  let!(:other_kc_family)   { create(:family, :kinship) }
  let!(:fc_family)         { create(:family, :foster) }
  let!(:othter_fc_family)  { create(:family, :foster) }
  let!(:ec_family)         { create(:family, :emergency) }
  let!(:referral_source)   { create(:referral_source) }

  context '#client_program_stream' do
    before do
      @program_stream_report = Dashboard.new(Client.all).client_program_stream.first
    end

    it 'should return attribute size 3' do
      expect(@program_stream_report.to_json).to have_json_size(3)
    end

    it 'should return attribute name' do
      program_stream_report = @program_stream_report.to_json
      expect(program_stream_report).to have_json_path('name')
    end

    it 'should return attribute y' do
      program_stream_report = @program_stream_report.to_json
      expect(program_stream_report).to have_json_path('y')
    end

    it 'should return attribute url' do
      program_stream_report = @program_stream_report.to_json
      expect(program_stream_report).to have_json_path('url')
    end

    it 'should return program name' do
      program_stream_report = @program_stream_report
      expect(program_stream_report[:name]).to eq(program_stream.name)
      expect(program_stream_report[:y]).to eq(1)
      expect(program_stream_report[:url]).not_to eq('')
    end

    it 'should return client enrolled program' do
      program_stream_report = @program_stream_report
      expect(program_stream_report[:y]).to eq(1)
    end

    it 'should return program url not empty' do
      program_stream_report = @program_stream_report
      expect(program_stream_report[:url]).not_to eq('')
    end
  end

  context '#client_gender_statistic' do
    before do
      @client_gender_statistic_report = Dashboard.new(Client.all).client_gender_statistic
    end

    it 'should return client gender statistic size' do
      client_gender_statistic_report = @client_gender_statistic_report
      expect(client_gender_statistic_report.size).to eq(2)
    end

    it 'should return male clients active ec count' do
      client_gender_statistic_report = @client_gender_statistic_report
      expect(client_gender_statistic_report.first[:active_data].first[:y]).to eq(1)
    end

    it 'should return male clients active kc count' do
      client_gender_statistic_report = @client_gender_statistic_report
      expect(client_gender_statistic_report.first[:active_data].second[:y]).to eq(0)
    end

    it 'should return male clients active fc count' do
      client_gender_statistic_report = @client_gender_statistic_report
      expect(client_gender_statistic_report.first[:active_data].third[:y]).to eq(0)
    end

    it 'should return female clients active ec count' do
      client_gender_statistic_report = @client_gender_statistic_report
      expect(client_gender_statistic_report.last[:active_data].first[:y]).to eq(0)
    end

    it 'should return female clients active kc count' do
      client_gender_statistic_report = @client_gender_statistic_report
      expect(client_gender_statistic_report.last[:active_data].second[:y]).to eq(1)
    end

    it 'should return female clients active fc count' do
      client_gender_statistic_report = @client_gender_statistic_report
      expect(client_gender_statistic_report.last[:active_data].third[:y]).to eq(1)
    end
  end

  context '#client_status_statistic' do
    before do
      @client_status_statistic_report = Dashboard.new(Client.all).client_status_statistic
    end

    it 'should return clients active fc count' do
      client_status_statistic_report = @client_status_statistic_report
      expect(client_status_statistic_report.first[:y]).to eq(1)
    end

    it 'should return clients active ec count' do
      client_status_statistic_report = @client_status_statistic_report
      expect(client_status_statistic_report.first[:y]).to eq(1)
    end

    it 'should return clients active fc count' do
      client_status_statistic_report = @client_status_statistic_report
      expect(client_status_statistic_report.second[:y]).to eq(1)
    end

    it 'should return clients active kc count' do
      client_status_statistic_report = @client_status_statistic_report
      expect(client_status_statistic_report.third[:y]).to eq(1)
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

  context '#able_count' do
    it 'shoud return able clients count' do
      expect(Dashboard.new(Client.all).able_count).to eq(1)
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
      expect(Dashboard.new(Client.all).referral_source_count).to eq(1)
    end
  end

  context '#program_stream_count' do
    it 'shoud return program stream count' do
      expect(Dashboard.new(Client.all).program_stream_count).to eq(1)
    end
  end
end
