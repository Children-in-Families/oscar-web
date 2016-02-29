describe QuarterlyReport, 'associations' do
  it { is_expected.to belong_to(:case) }
  it { is_expected.to belong_to(:staff_information)}
end
