describe GovernmentFormProblem, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:problem) }
end
