describe Commune, 'association' do
  it { is_expected.to belong_to(:district) }
  it { is_expected.to have_many(:villages).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:government_forms).dependent(:restrict_with_error) }
end

describe Commune, 'validations' do
  it { is_expected.to validate_presence_of(:district) }
  it { is_expected.to validate_presence_of(:name_kh) }
  it { is_expected.to validate_presence_of(:name_en) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code) }
end

describe Commune, 'methods' do
  let(:commune_1){ create(:commune, name_kh: 'ABC', name_en: 'DEF', code: '123456') }
  context '#name' do
    it 'returns name_kh / name_en' do
      expect(commune_1.name).to eq('ABC / DEF')
    end
  end

  context '#code_format' do
    it 'returns name_kh / name_en (code)' do
      expect(commune_1.code_format).to eq('ABC / DEF (123456)')
    end
  end
end
