describe Survey, 'associations' do
  it { is_expected.to belong_to(:client) }
end

describe Survey, 'validations' do
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:listening_score) }
  it { is_expected.to validate_presence_of(:problem_solving_score) }
  it { is_expected.to validate_presence_of(:getting_in_touch_score) }
  it { is_expected.to validate_presence_of(:trust_score) }
  it { is_expected.to validate_presence_of(:difficulty_help_score) }
  it { is_expected.to validate_presence_of(:support_score) }
  it { is_expected.to validate_presence_of(:family_need_score) }
  it { is_expected.to validate_presence_of(:care_score) }
end
