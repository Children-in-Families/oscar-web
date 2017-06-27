describe Tracking, 'associations' do
  it { is_expected.to belong_to(:program_stream) }
  it { is_expected.to have_many(:client_enrollments).through(:client_enrollment_trackings) }
  it { is_expected.to have_many(:client_enrollment_trackings).dependent(:restrict_with_error) }
end

describe Tracking, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:fields) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:program_stream_id) }
end

describe Tracking, 'form_builder_field_uniqueness' do
  fields = [ {'label'=>'world','type'=>'text'}, {'label'=>'world','type'=>'text'} ]
  duplicate_tracking = Tracking.create(name: 'test', fields: fields)

  it 'return field duplicated' do
    duplicate_tracking.save
    expect(duplicate_tracking.errors.full_messages).to include("Fields Fields duplicated!")
  end
end

describe Tracking, 'validate remove field' do
  let!(:program_stream) { create(:program_stream) }
  let!(:tracking) { create(:tracking, program_stream: program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream)}
  let!(:client_enrollment_tracking) { create(:client_enrollment_tracking, tracking: tracking, client_enrollment: client_enrollment) }

  it 'return cannot remove or update' do
    fields = [{"name"=>"email", "type"=>"text", "label"=>"e-mail", "subtype"=>"email", "required"=>true, "className"=>"form-control"}, {"max"=>"5", "min"=>"1", "name"=>"age", "type"=>"number", "label"=>"age", "required"=>true, "className"=>"form-control"}]
    tracking.update_attributes(fields: fields)
    expect(tracking.errors.full_messages).to include("Fields description cannot be removed/updated since it is already in use.")
  end
end

