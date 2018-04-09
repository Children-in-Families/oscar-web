describe ExitNgo, 'associations' do
  it { is_expected.to belong_to(:client) }
end

describe ExitNgo, 'validations' do
  it { is_expected.to validate_presence_of(:exit_circumstance)}
  it { is_expected.to validate_presence_of(:exit_note)}
  it { is_expected.to validate_presence_of(:exit_date)}
end

describe ExitNgo, 'callbacks' do
  context 'after_create' do
    context 'update_client_status' do
      let!(:user_manager){ create(:user, :manager) }
      context 'referred_client' do
        let!(:client){ create(:client) }
        let!(:exit_ngo) { create(:exit_ngo, client: client) }

        it { expect(client.reload.status).to eq('Exited') }
      end

      context 'accepted_client' do
        let!(:client){ create(:client, :accepted) }
        let!(:exit_ngo) { create(:exit_ngo, client: client) }

        it { expect(client.reload.status).to eq('Exited') }
      end
    end
  end
end

describe ExitNgo, 'scopes' do
  let!(:manager){ create(:user, :manager) }
  let!(:exit_ngo_1){ create(:exit_ngo) }
  let!(:exit_ngo_2){ create(:exit_ngo) }

  context '.most_recents' do
    subject { ExitNgo.most_recents.first }

    it 'return last record' do
      is_expected.to eq(exit_ngo_2)
    end

    it 'return first record' do
      is_expected.not_to eq(exit_ngo_1)
    end
  end
end
