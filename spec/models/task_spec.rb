describe Task, 'associations' do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:domain)}
  it { is_expected.to belong_to(:case_note_domain_group)}
  it { is_expected.to belong_to(:client)}
end

describe Task, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:domain_id) }
  it { is_expected.to validate_presence_of(:completion_date) }
end
