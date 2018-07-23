describe ClientRight, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end

describe ClientRight, 'associations' do
  it { is_expected.to have_many(:client_right_government_forms).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:client_rights).through(:client_right_government_forms) }
end
