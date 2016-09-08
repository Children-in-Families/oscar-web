describe Changelog, 'associations' do
  it { is_expected.to belong_to(:user)}
end

describe Changelog, 'validations' do
  it { is_expected.to validate_presence_of(:version)}
  it { is_expected.to validate_presence_of(:description)}
  it { is_expected.to validate_uniqueness_of(:version)}
end
