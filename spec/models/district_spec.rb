describe District, 'associations'do
  it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
  it { is_expected.to belong_to(:province) }
end

describe District, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:province) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:province_id) }
end
