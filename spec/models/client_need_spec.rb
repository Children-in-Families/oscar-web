describe ClientNeed, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:need) }
end
