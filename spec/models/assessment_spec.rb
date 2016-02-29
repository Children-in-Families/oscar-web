describe Assessment, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to have_many(:assessment_domains) }
  it { is_expected.to have_many(:domains) }
  it { is_expected.to have_many(:case_notes) }

  it { is_expected.to accept_nested_attributes_for(:assessment_domains) }
end

describe Assessment, 'validations' do
  xit { is_expected.to validate_presence_of(:client_id) }
end
