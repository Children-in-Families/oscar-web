describe EnterNgo, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to have_many(:enter_ngo_users).dependent(:destroy) }
  it { is_expected.to have_many(:users).through(:enter_ngo_users) }
end

describe EnterNgo, 'validations' do
  it { is_expected.to validate_presence_of(:accepted_date) }

  context 'on_create' do
    context 'exited_client' do
      context 'user_ids' do
        let!(:manager){create(:user, :manager) }
        let!(:exited_client) { create(:client, :exited) }

        it 'invalid' do
          enter_ngo = FactoryGirl.build(:enter_ngo, client: exited_client)
          enter_ngo.save
          expect(enter_ngo.valid?).to be_falsey
          expect(enter_ngo.errors.full_messages).to include("User ids can't be blank")
        end

        it 'valid' do
          enter_ngo = FactoryGirl.build(:enter_ngo, client: exited_client, user_ids: [manager.id])
          enter_ngo.save
          expect(enter_ngo.valid?).to be_truthy
        end
      end
    end
  end
end

describe EnterNgo, 'callbacks' do
  context 'after_create' do
    context 'update_client_status' do
      let!(:manager){ create(:user, :manager) }
      context 'exited_client' do
        let!(:client){ create(:client, :exited) }
        let!(:enter_ngo) { create(:enter_ngo, client: client, user_ids: [manager.id]) }

        it { expect(client.reload.status).to eq('Accepted') }
      end
    end
  end
end

describe EnterNgo, 'scopes' do
  let!(:enter_ngo_1){ create(:enter_ngo) }
  let!(:enter_ngo_2){ create(:enter_ngo) }

  context '.most_recents' do
    subject { EnterNgo.most_recents.first }
    it 'return last record' do
      is_expected.to eq(enter_ngo_2)
    end
    it 'return first record' do
      is_expected.not_to eq(enter_ngo_1)
    end
  end
end
