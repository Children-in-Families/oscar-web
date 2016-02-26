describe AssessmentDomain, 'associations' do
  it { is_expected.to belong_to(:assessment)}
  it { is_expected.to belong_to(:domain)}
end

describe AssessmentDomain, 'validations' do
  it { is_expected.to validate_presence_of(:domain_id) }
end
