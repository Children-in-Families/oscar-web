describe Partner, 'associations' do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to have_many(:cases) }
end
