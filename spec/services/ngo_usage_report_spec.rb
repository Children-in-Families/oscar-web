describe NgoUsageReport, 'generator' do
  let(:beginning_of_month){ Date.today.beginning_of_month }
  let(:end_of_month){ Date.today.end_of_month }
  let!(:user_1){ create(:user) }
  let!(:user_2){ create(:user) }
  let!(:two_visits){ create_list(:visit, 2, user: user_2) }
  let!(:client_1){ create(:client, user_ids: [user_2.id], received_by: user_2) }
  let!(:two_referrals){ create_list(:referral, 2, client: client_1, slug: client_1.slug) }

  context '#ngo_info' do
    before do
      @report = NgoUsageReport.new
    end

    it 'returns NGO info' do
      Organization.current.update(created_at: Date.today)

      expect(@report.ngo_info(Organization.current)).to eq({
        ngo_name: 'Organization Testing',
        ngo_on_board: date_format(Date.today),
        fcf: 'No',
        ngo_country: 'Cambodia'
      })
    end

    it 'returns NGO Users info' do
      user_1.destroy

      expect(@report.ngo_users_info(beginning_of_month, end_of_month)).to eq({
        # check clients factory for why there are 2 users
        user_count: 2,
        user_added_count: 3,
        user_deleted_count: 1,
        login_per_month: 2
      })
    end

    it 'returns NGO Clients info' do
      expect(@report.ngo_clients_info(beginning_of_month, end_of_month)).to eq({
        client_count: 1,
        client_added_count: 1,
        client_deleted_count: 0
      })
    end

    it 'returns NGO Referrals info' do
      expect(@report.ngo_referrals_info(beginning_of_month, end_of_month)).to eq({
        tranferred_client_count: 1
      })
    end
  end
end
