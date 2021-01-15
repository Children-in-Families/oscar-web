describe Community, 'associations' do
  it { is_expected.to have_many(:enrollments).dependent(:destroy) }
  it { is_expected.to have_many(:program_streams).through(:enrollments) }
  it { is_expected.to have_many(:custom_field_properties).dependent(:destroy) }
  it { is_expected.to have_many(:custom_fields).through(:custom_field_properties) }
end
