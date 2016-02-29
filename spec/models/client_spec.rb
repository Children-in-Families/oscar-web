describe Client, 'associations' do

  it { is_expected.to belong_to(:referral_source) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:received_by) }
  it { is_expected.to belong_to(:followed_up_by) }
  it { is_expected.to belong_to(:birth_province) }

  it { is_expected.to have_many(:cases) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:case_notes) }
  it { is_expected.to have_many(:assessments) }

  it { is_expected.to have_and_belong_to_many(:agencies) }
  it { is_expected.to have_and_belong_to_many(:quantitative_cases) }

end
