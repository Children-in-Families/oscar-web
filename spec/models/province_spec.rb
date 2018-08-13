describe Province, 'associations'do
  it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:families).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:partners).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:cases).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:districts).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:settings).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:government_forms).dependent(:restrict_with_error) }
end

describe Province, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:country) }
end

describe Province, '.scopes' do
  let!(:phnom_penh){ create(:province, country: 'cambodia', name: 'ភ្នំពេញ / Phnom Penh') }
  let!(:bangkok){ create(:province, country: 'thailand', name: 'Bangkok') }

  context '.country_is(...)' do
    it { expect(Province.country_is('cambodia').ids).to include(phnom_penh.id) }
    it { expect(Province.country_is('cambodia').ids).not_to include(bangkok.id) }

    it { expect(Province.country_is('thailand').ids).to include(bangkok.id) }
    it { expect(Province.country_is('thailand').ids).not_to include(phnom_penh.id) }
  end

  context '.has_clients' do
    let!(:client_1){ create(:client, province: phnom_penh) }

    it 'returns only provinces which are attached to clients' do
      expect(Province.has_clients.ids).to include(phnom_penh.id)
      expect(Province.has_clients.ids).not_to include(bangkok.id)
    end
  end

  xcontext '.birth_places' do
  end

  context '.official' do
    let!(:province_1){ create(:province, name: 'បោយប៉ែត/Poipet') }
    let!(:province_2){ create(:province, name: 'Community') }
    let!(:province_3){ create(:province, name: 'Other / ផ្សេងៗ') }
    let!(:province_4){ create(:province, name: 'នៅ​ខាង​ក្រៅ​កម្ពុជា / Outside Cambodia') }

    it 'returns 25 provinces of Cambodia' do
      expect(Province.official.ids).to include(phnom_penh.id)
      expect(Province.official.ids).not_to include([province_1.id, province_2.id, province_3.id, province_4.id])
    end
  end
end

describe Province, 'methods' do
  let!(:province_1){ create(:province, name: 'ភ្នំពេញ / Phnom Penh') }
  let!(:province_2){ create(:province) }
  let!(:client){ create(:client, province: province_1) }
  context '#removeable?' do
    it 'returns false if the province is attached to any resources' do
      expect(province_1.removeable?).to be_falsey
      expect(province_2.removeable?).to be_truthy
    end
  end

  context '#name_kh' do
    it 'returns Khmer name' do
      expect(province_1.name_kh).to eq('ភ្នំពេញ')
    end
  end
end
