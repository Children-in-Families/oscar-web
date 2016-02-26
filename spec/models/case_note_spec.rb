describe CaseNote, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:assessment) }
  it { is_expected.to have_many(:case_note_domain_groups) }
  it { is_expected.to have_many(:domain_groups) }

  it { is_expected.to accept_nested_attributes_for(:case_note_domain_groups) }
end

