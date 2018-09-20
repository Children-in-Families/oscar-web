describe Village, 'associations' do
  it { is_expected.to belong_to(:commune) }
  it { is_expected.to have_many(:government_forms).dependent(:restrict_with_error) }
end

describe Village, 'validations' do
  it { is_expected.to validate_presence_of(:commune) }
  it { is_expected.to validate_presence_of(:name_kh) }
  it { is_expected.to validate_presence_of(:name_en) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code) }
end

describe Village, 'methods' do
  let!(:village_1){ create(:village, name_kh: 'ABC', name_en: 'DEF', code: '123456') }
  context '#code_format' do
    it 'returns name_kh / name_en (code)' do
      expect(village_1.code_format).to eq('ABC / DEF (123456)')
    end
  end
end
