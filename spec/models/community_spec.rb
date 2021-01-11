describe Community, 'associations' do
  it { is_expected.to have_many(:enrollments).dependent(:destroy) }
  it { is_expected.to have_many(:program_streams).through(:enrollments) }
end
