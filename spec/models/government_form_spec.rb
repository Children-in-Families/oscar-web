describe GovernmentForm, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:province) }
  it { is_expected.to belong_to(:district) }
  it { is_expected.to belong_to(:commune) }
  it { is_expected.to belong_to(:village) }
  it { is_expected.to have_many(:government_form_interviewees).dependent(:destroy) }
  it { is_expected.to have_many(:interviewees).through(:government_form_interviewees) }
  it { is_expected.to have_many(:client_type_government_forms).dependent(:destroy) }
  it { is_expected.to have_many(:client_types).through(:client_type_government_forms) }
  it { is_expected.to have_many(:government_form_needs).dependent(:destroy) }
  it { is_expected.to have_many(:needs).through(:government_form_needs) }
  it { is_expected.to have_many(:government_form_problems).dependent(:destroy) }
  it { is_expected.to have_many(:problems).through(:government_form_problems) }
end
