describe District, 'associations'do
  it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:families).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:subdistricts).dependent(:destroy) }
  it { is_expected.to have_many(:communes).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:government_forms).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:settings).dependent(:restrict_with_error) }

  it { is_expected.to belong_to(:province) }
end

describe District, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:province) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:province_id) }
end

describe District, 'methods' do
  let!(:district_1){ create(:district, name: 'ចំការមន / Chamkamon') }
  context '#name_kh' do
    it 'returns Khmer name' do
      expect(district_1.name_kh).to eq('ចំការមន')
    end
  end
end
