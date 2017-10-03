describe ClientProblem, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:problem) }
end
