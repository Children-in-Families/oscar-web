describe ClientTypeGovernmentForm, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:client_type) }
end
