describe ClientRight, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
end

describe ClientRight, 'associations' do
  it { is_expected.to have_many(:client_right_government_forms) }
  it { is_expected.to have_many(:client_rights).through(:client_right_government_forms) }
end
