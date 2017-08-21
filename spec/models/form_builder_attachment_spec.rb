describe FormBuilderAttachment, 'associations' do
  it { is_expected.to belong_to(:form_buildable)}
end

describe FormBuilderAttachment, 'validations' do
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:form_buildable_type, :form_buildable_id) }
end
