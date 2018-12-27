describe Domain, 'associations' do
  it { is_expected.to belong_to(:domain_group) }
  it { is_expected.to have_many(:assessment_domains).dependent(:restrict_with_error)}
  it { is_expected.to have_many(:tasks).dependent(:restrict_with_error)}
end

describe Domain, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:identity) }
  it { is_expected.to validate_presence_of(:domain_group) }

  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:custom_domain) }
  it { is_expected.to validate_uniqueness_of(:identity).case_insensitive.scoped_to(:custom_domain) }
end

describe Domain, 'methods' do
  context 'convert_identity' do
    let!(:domain){ create(:domain) }
    it 'should return identity with underscore' do
      expect(domain.convert_identity).to eq(domain.identity.downcase.parameterize('_'))
    end
  end
end

describe Domain, 'scopes' do
  let!(:domain){ create(:domain, custom_domain: false) }
  let!(:custom_domain){ create(:domain, custom_domain: true) }

  it '.csi_domains' do
    domains = Domain.csi_domains
    expect(domains).to include(domain)
    expect(domains).not_to include(custom_domain)
  end

  it '.custom_csi_domains' do
    domains = Domain.custom_csi_domains
    expect(domains).to include(custom_domain)
    expect(domains).not_to include(domain)
  end
end
