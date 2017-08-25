describe VisitClient, 'associations' do
  it { is_expected.to belong_to(:user)}
end

describe VisitClient, 'class methods' do
  let!(:user_1) { create(:user) }
  context 'initial_visit_client(user)' do
    subject { VisitClient.initial_visit_client(user_1) }
    it 'should create a visit_client record of that user' do
      is_expected.to eq(user_1.visit_clients.last)
    end
  end
end
