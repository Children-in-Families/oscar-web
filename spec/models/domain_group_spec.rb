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

  context '#default_domain_identities' do
    let!(:default_domain_group) { create(:domain_group, aht: false) }
    let!(:aht_domain_group) { create(:domain_group, aht: true) }

    it 'returns dimension_identies list' do
      allow_any_instance_of(Organization).to receive(:aht).and_return(true)
      expect(aht_domain_group.default_domain_identities).to eq("Physical health, Work skills and education")
    end

    it 'returns default domain_identies list' do
      expect(default_domain_group.default_domain_identities).to eq("Food Security, Nutrition and Growth")
    end
  end
end
