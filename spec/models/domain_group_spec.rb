describe DomainGroup, 'associations' do
  it { is_expected.to have_many(:domains)}
end

describe DomainGroup, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end

describe DomainGroup, 'scopes' do
  let!(:domain_group){ create(:domain_group, name: '1A')}
  let!(:other_domain_group){ create(:domain_group, name: '2A')}
  context 'default scope' do
    it 'should order by name' do
      expect(DomainGroup.all).to eq([domain_group, other_domain_group])
    end
  end
end


describe DomainGroup, 'methods' do
  let!(:domain_group){ create(:domain_group) }
  let!(:domain){ create(:domain, domain_group: domain_group) }
  let!(:other_domain){ create(:domain, domain_group: domain_group) }
  let!(:domain_identities){ "#{domain.identity}, #{other_domain.identity}" }
  it { expect(domain_group.domain_identities).to eq(domain_identities) }
end