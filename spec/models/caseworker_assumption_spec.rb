describe CaseworkerAssumption, 'associations' do
  it { is_expected.to have_many(:caseworker_assumption_government_forms).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:government_forms).through(:caseworker_assumption_government_forms) }
end

describe CaseworkerAssumption, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
