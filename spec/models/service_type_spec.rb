describe ServiceType, 'associations' do
  it { is_expected.to have_many(:government_form_service_types).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:government_forms).through(:government_form_service_types) }
end

describe ServiceType, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
end
