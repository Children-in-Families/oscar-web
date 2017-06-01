describe ClientEnrollment, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:program_stream) }
  it { is_expected.to have_many(:trackings) }
  it { is_expected.to have_one(:leave_program) }
end

describe ClientEnrollment, 'scopes' do
  let!(:client) { create(:client) }
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client)}

  properties = {"Select"=>"Option 3", "Text Area"=>"daf", "Text Field"=>"asdf", "Radio Group"=>"Option 2", "Checkbox Group"=>["Option 1", ""]}.to_json
  let!(:exited_status_client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client, status: 'Exited', properties: properties) }
  

  context 'enrollments_by' do
    let!(:enrollments_by){ ClientEnrollment.enrollments_by(client, program_stream) }
    it 'find client enrollments' do
      expect(enrollments_by).to include(client_enrollment)
    end
  end

  context 'active' do
    let!(:active_status){ ClientEnrollment.active }
    it 'should return client enrollment with active status' do
      expect(active_status).to include(client_enrollment)
    end

    it 'should return client enrollment with exited status' do
      expect(active_status).not_to include(exited_status_client_enrollment) 
    end
  end
end

describe ClientEnrollment, 'validation of presence, email and numberical fields' do
  let!(:client) { create(:client) }
  let!(:program_stream) { create(:program_stream) }
  properties = {"Select"=>"Option 3", "Text Area"=>"daf", "Text Field"=>"asdf", "Radio Group"=>"Option 2", "Checkbox Group"=>["Option 1", ""]}.to_json
  client_enrollment = ClientEnrollment.new(client_id: client, program_stream_id: program_stream, properties: properties)
  # let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client)}


  it 'it return cant be blank' do
    
  end
end