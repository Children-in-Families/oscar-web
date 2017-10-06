describe ClientClientType, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:client_type) }
end
