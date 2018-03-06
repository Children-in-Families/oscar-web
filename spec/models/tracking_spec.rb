describe Tracking, 'associations' do
  it { is_expected.to belong_to(:program_stream) }
  it { is_expected.to have_many(:client_enrollments).through(:client_enrollment_trackings) }
  it { is_expected.to have_many(:client_enrollment_trackings).dependent(:restrict_with_error) }
end

describe Tracking, 'validations' do
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

describe 'validate presence of label field' do
  let!(:program_stream) {:program_stream}

  context 'valid' do
    fields = [{"name"=>"date-1497520151012", "type"=>"date", "label"=>"Date", "className"=>"calendar"}]
    valid_tracking = FactoryGirl.build(:tracking, fields: fields)
    it{ expect(valid_tracking.valid?).to be_truthy }
  end

  context 'invalid' do
    fields = [{"name"=>"date-1497520151012", "type"=>"date", "label"=>"", "className"=>"calendar"}]
    invalid_tracking = FactoryGirl.build(:tracking, fields: fields)
    invalid_tracking.valid?
    it{ expect(invalid_tracking.errors[:fields]).to include("Label can't be blank") }
  end
end

describe Tracking, 'method' do
  let!(:program_stream) { create(:program_stream) }
  let!(:program_stream_other) { create(:program_stream) }
  let!(:tracking) { create(:tracking, program_stream: program_stream) }
  let!(:tracking_other) { create(:tracking, program_stream: program_stream_other) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream)}
  let!(:client_enrollment_tracking) { create(:client_enrollment_tracking, tracking: tracking, client_enrollment: client_enrollment) }

  it 'is_used?' do
    expect(tracking.is_used?).to be_truthy
    expect(tracking_other.is_used?).to be_falsey
  end
end

describe Tracking, 'scopes' do
  let!(:program_stream) { create(:program_stream) }
  let!(:tracking) { create(:tracking, program_stream: program_stream) }
  let!(:another_tracking) { create(:tracking, program_stream: program_stream) }

  context 'default_scope' do
    it 'should order tracking by create_at' do
      expect(program_stream.trackings.all).to eq([tracking, another_tracking])
    end
  end
end
