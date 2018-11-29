describe DomainGroup, 'associations' do
  it { is_expected.to have_many(:domains)}
end

describe DomainGroup, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end

describe DomainGroup, 'scopes' do
  let!(:domain_group){ create(:domain_group, name: '1A')}
  let!(:other_domain_group){ create(:domain_group, name: '2A')}
  context 'default scope' do
    it 'should order by id and name' do
      expect(DomainGroup.all).to eq([domain_group, other_domain_group])
    end
  end
end


describe DomainGroup, 'methods' do
  let!(:domain_group){ create(:domain_group, name: '1') }
  let!(:domain_group_2){ create(:domain_group, name: '2') }
  let!(:domain){ create(:domain, domain_group: domain_group) }
  let!(:other_domain){ create(:domain, domain_group: domain_group) }

  context '#first_ordered?' do
    it 'returns true' do
      expect(domain_group.first_ordered?). to be_truthy
    end
    it 'returns false' do
      expect(domain_group_2.first_ordered?). to be_falsey
    end
  end
end
