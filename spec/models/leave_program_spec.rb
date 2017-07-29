describe LeaveProgram, 'associations' do
  it { is_expected.to belong_to(:client_enrollment) }
  it { is_expected.to belong_to(:program_stream) }
end

describe LeaveProgram, 'validations' do
  it { is_expected.to validate_presence_of(:exit_date) }

  let!(:client) { create(:client) }
  let!(:program_stream) { create(:program_stream)}

  context 'custom form email validator' do
    it 'return is not an email' do
      properties = {"e-mail"=>"cifcambodianfamily", "age"=>"3", "description"=>"this is testing"}
      client_enrollment = ClientEnrollment.new(program_stream: program_stream, client: client, properties: properties)
      client_enrollment.save
      expect(client_enrollment.errors.full_messages).to include("E-mail is not an email")
    end
  end

  context 'custom form present validator' do
    it 'return cant be blank' do
      properties = {"e-mail"=>"test@example.com", "age"=>"3", "description"=>""}
      client_enrollment = ClientEnrollment.new(program_stream: program_stream, client: client, properties: properties)
      client_enrollment.save
      expect(client_enrollment.errors.full_messages).to include("Description can't be blank")
    end 
  end

  context 'custom form number validator' do
    it 'return cant be greater' do
      properties = {"e-mail"=>"test@example.com", "age"=>"6", "description"=>"this is testing"}
      client_enrollment = ClientEnrollment.new(program_stream: program_stream, client: client, properties: properties)
      client_enrollment.save
      expect(client_enrollment.errors.full_messages).to include("Age can't be greater than 5")
    end 

    it 'return cant be lower' do
      properties = {"e-mail"=>"test@example.com", "age"=>"0", "description"=>"this is testing"}
      client_enrollment = ClientEnrollment.new(program_stream: program_stream, client: client, properties: properties)
      client_enrollment.save
      expect(client_enrollment.errors.full_messages).to include("Age can't be lower than 1")
    end 
  end
end

describe LeaveProgram, 'callbacks' do
  let!(:program_stream) { create(:program_stream) }
  let!(:case_client) { create(:client) }
  let!(:case) { create(:case, client: case_client) }
  let!(:case_client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: case_client) }

  let!(:client) { create(:client) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client) }

  context 'set_client_status' do
    let!(:case_leave_program) { create(:leave_program, client_enrollment: case_client_enrollment, program_stream: program_stream) }
    let!(:leave_program) { create(:leave_program, client_enrollment: client_enrollment, program_stream: program_stream) }
    it 'return client status Active EC when in EC' do
      case_leave_program.reload
      case_leave_program.update(exit_date: FFaker::Time.date)
      expect(case_leave_program.client_enrollment.client.status).to eq("Active EC")
    end

    it 'return client status Referred when not in any case' do
      leave_program.reload
      leave_program.update(exit_date: FFaker::Time.date)
      expect(leave_program.client_enrollment.client.status).to eq("Referred")
    end
  end
end
