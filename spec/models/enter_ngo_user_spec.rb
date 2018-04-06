describe EnterNgoUser, 'associations' do
  it { is_expected.to belong_to(:enter_ngo) }
  it { is_expected.to belong_to(:user) }
end
