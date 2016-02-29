describe Family, 'associations' do
  it { is_expected.to belong_to(:province) }
  it { is_expected.to have_many(:cases) }
  it { is_expected.not_to have_many(:tranings) }
end
