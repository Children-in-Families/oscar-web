describe GovernmentReport, 'associations' do
  it { is_expected.to belong_to(:client) }
end

describe GovernmentReport, 'validations' do
  it { is_expected.to validate_presence_of(:client)}
  it { is_expected.to validate_presence_of(:code)}
  
  context 'uniqueness of code' do
    let!(:government_report) { create(:government_report, code: 'abc') }
    it 'is valid' do
      valid_report = build(:government_report, code: 'def')
      expect(valid_report.save).to be true
    end

    it 'is invalid' do
      invalid_report = build(:government_report, code: 'abc')
      expect(invalid_report.save).to be false
    end
  end
end

describe GovernmentReport, 'callbacks' do
  context 'enable disable missions' do
    let!(:government_report) { create(:government_report, code: FFaker::Lorem.words, mission_obtainable: false) }

    it "all missions should be false" do
      expect(government_report.first_mission).to be false
      expect(government_report.second_mission).to be false
      expect(government_report.third_mission).to be false
      expect(government_report.fourth_mission).to be false
    end
  end
end