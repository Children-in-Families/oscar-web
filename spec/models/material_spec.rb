describe Material, 'validations' do
  it { is_expected.to validate_presence_of(:status)}
  it { is_expected.to validate_uniqueness_of(:status)}
end
