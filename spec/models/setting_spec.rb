describe Setting, 'validation' do
  let!(:setting){ create(:setting) }

  it { is_expected.to validate_numericality_of(:min_assessment).only_integer }
  it { is_expected.to validate_numericality_of(:min_assessment).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:max_assessment).only_integer }
  it { is_expected.to validate_numericality_of(:max_assessment).is_greater_than(0) }
end
