describe Domain, 'associations' do
  it { is_expected.to belong_to(:domain_group) }
  it { is_expected.to have_many(:assessment_domains).dependent(:restrict_with_error)}
  it { is_expected.to have_many(:tasks).dependent(:restrict_with_error)}
end

describe Domain, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:identity) }
  it { is_expected.to validate_presence_of(:domain_group) }

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_uniqueness_of(:identity).case_insensitive }
end

describe Domain, 'methods' do
  context 'convert_identity' do
    let!(:domain){ create(:domain) }
    it 'should return identity with underscore' do
      expect(domain.convert_identity).to eq(domain.identity.downcase.parameterize('_'))
    end
  end
end
