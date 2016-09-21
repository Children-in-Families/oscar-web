describe Material, 'associations' do
  it { is_expected.to have_many(:progress_notes).dependent(:restrict_with_error)}
end

describe Material, 'validations' do
  it { is_expected.to validate_presence_of(:status)}
  it { is_expected.to validate_uniqueness_of(:status)}
end
