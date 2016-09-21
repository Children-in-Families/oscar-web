describe Location, 'associations' do
  it { is_expected.to have_many(:progress_notes).dependent(:restrict_with_error)}
end

describe Location, 'validations' do
  it { is_expected.to validate_presence_of(:name)}
  it { is_expected.to validate_uniqueness_of(:name)}
end
