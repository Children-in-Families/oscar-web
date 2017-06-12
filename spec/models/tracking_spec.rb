describe Tracking, 'associations' do
  it { is_expected.to belong_to(:program_stream) }
  it { is_expected.to have_many(:client_enrollments).through(:client_enrollment_trackings) }
  it { is_expected.to have_many(:client_enrollment_trackings).dependent(:restrict_with_error) }
end

describe Tracking, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
end

describe Tracking, 'duplicate field' do
  fields = [ {'label'=>'world','type'=>'text'}, {'label'=>'world','type'=>'text'} ]
  duplicate_tracking = Tracking.create(name: 'test', fields: fields)

  it 'return field duplicate' do
    duplicate_tracking.save
    expect(duplicate_tracking.errors.full_messages).to include("Fields Fields duplicated!")
  end
end

describe Tracking, 'validate remove field' do
  let(:tracking) { create(:tracking) }

  it 'return cannot remove or update' do
    fields = [{"name"=>"email", "type"=>"text", "label"=>"e-mail", "subtype"=>"email", "required"=>true, "className"=>"form-control"}, {"max"=>"5", "min"=>"1", "name"=>"age", "type"=>"number", "label"=>"age", "required"=>true, "className"=>"form-control"}]
    tracking.update_attributes(fields: fields)
    expect(page).to include("cannot remove/update")
  end
end
# describe Tracking, 'custom form validator' do
#   let!(:client) { create(:client) }
#   let!(:program_stream) { create(:program_stream)}

#   context 'custom form email validator' do
#     it 'return is not an email' do
#       properties = {"e-mail"=>"cifcambodianfamily", "age"=>"3", "description"=>"this is testing"}
#       client_enrollment = ClientEnrollment.new(program_stream: program_stream, client: client, properties: properties)
#       client_enrollment.save
#       expect(client_enrollment.errors.full_messages).to include("E-mail is not an email")
#     end
#   end

#   context 'custom form present validator' do
#     it 'return cant be blank' do
#       properties = {"e-mail"=>"cif@cambodianfamily.com", "age"=>"3", "description"=>""}
#       client_enrollment = ClientEnrollment.new(program_stream: program_stream, client: client, properties: properties)
#       client_enrollment.save
#       expect(client_enrollment.errors.full_messages).to include("Description can't be blank")
#     end 
#   end

#   context 'custom form number validator' do
#     it 'return cant be greater' do
#       properties = {"e-mail"=>"cif@cambodianfamily.com", "age"=>"6", "description"=>"this is testing"}
#       client_enrollment = ClientEnrollment.new(program_stream: program_stream, client: client, properties: properties)
#       client_enrollment.save
#       expect(client_enrollment.errors.full_messages).to include("Age can't be greater than 5")
#     end 

#     it 'return cant be lower' do
#       properties = {"e-mail"=>"cif@cambodianfamily.com", "age"=>"0", "description"=>"this is testing"}
#       client_enrollment = ClientEnrollment.new(program_stream: program_stream, client: client, properties: properties)
#       client_enrollment.save
#       expect(client_enrollment.errors.full_messages).to include("Age can't be lower than 1")
#     end 
#   end
# end
