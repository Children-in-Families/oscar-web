describe ReferralSource, 'validation' do
  it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
