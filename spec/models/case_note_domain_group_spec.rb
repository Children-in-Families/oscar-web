describe CaseNoteDomainGroup, 'associations' do
  it { is_expected.to belong_to(:case_note)}
  it { is_expected.to belong_to(:domain_group)}
  it { is_expected.to have_many(:tasks)}
end
