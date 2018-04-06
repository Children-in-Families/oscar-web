describe Setting, 'validation' do
  it { is_expected.to validate_numericality_of(:min_assessment).only_integer.is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:max_assessment).only_integer.is_greater_than(0) }
end
