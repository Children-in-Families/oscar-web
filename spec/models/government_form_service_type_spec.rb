describe GovernmentFormServiceType, 'associations' do
  it { is_expected.to belong_to(:government_form) }
  it { is_expected.to belong_to(:service_type) }
end
