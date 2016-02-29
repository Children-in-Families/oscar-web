describe Case, 'associations' do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:family) }
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:partner) }
  it { is_expected.to belong_to(:province) }

  it { is_expected.to have_many(:case_contracts) }
  it { is_expected.to have_many(:quarterly_reports) }
end

describe Case, 'validations' do
  subject{ Case.new(case_type: 'FC') }
  xit { is_expected.to validate_presence_of(:case_type) }
  it { is_expected.to validate_presence_of(:family) }

end
