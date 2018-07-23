describe CaseworkerAssumptionGovernmentForm, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:caseworker_assumption) }
end
