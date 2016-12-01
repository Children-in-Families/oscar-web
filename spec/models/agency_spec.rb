describe Agency, 'associations' do
  it { is_expected.to have_many(:agency_clients) }
  it { is_expected.to have_many(:clients).through(:agency_clients)}
end

describe Agency, 'validations' do
  it { is_expected.to validate_presence_of(:name)}
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end

describe Agency, 'scopes' do
  let!(:agency){ create(:agency, name: 'Samnang') }
  let!(:other_agency){ create(:agency, name: 'agency') }
  context 'name like' do
    it 'should include agency with name like' do
        expect(Agency.name_like([agency.name])).to include(agency)
    end
    it 'should not include agency with other name' do
        expect(Agency.name_like([agency.name])).not_to include(other_agency)
    end
  end
end
