describe Province, 'associations'do
  it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:families).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:partners).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:cases).dependent(:restrict_with_error) }
end

describe Province, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:country) }
end

describe Province, '.scopes' do
  let!(:phnom_penh){ create(:province, country: 'cambodia') }
  let!(:bangkok){ create(:province, country: 'thailand') }
  context '.country_is(...)' do
    it { expect(Province.country_is('cambodia').ids).to include(phnom_penh.id) }
    it { expect(Province.country_is('cambodia').ids).not_to include(bangkok.id) }

    it { expect(Province.country_is('thailand').ids).to include(bangkok.id) }
    it { expect(Province.country_is('thailand').ids).not_to include(phnom_penh.id) }
  end
end
