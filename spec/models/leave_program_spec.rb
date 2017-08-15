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
  let!(:ec_client) { create(:client) }
  let!(:client) { create(:client) }
  let!(:ec_case) { create(:case, :emergency, client: ec_client) }
  let!(:first_program_stream) { create(:program_stream) }
  let!(:second_program_stream) { create(:program_stream) }
  let!(:third_program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, client: ec_client, program_stream: first_program_stream) }
  let!(:first_client_enrollment) { create(:client_enrollment, client: client, program_stream: first_program_stream) }
  let!(:second_client_enrollment) { create(:client_enrollment, client: client, program_stream: second_program_stream) }
  let!(:third_client_enrollment) { create(:client_enrollment, client: client, program_stream: third_program_stream) }

  context 'set_client_status' do
    context 'The client is Active EC' do
      let!(:leave_program) { create(:leave_program, client_enrollment: client_enrollment, program_stream: first_program_stream) }
      it 'status should remain Active EC' do
        expect(ec_client.status).to eq('Active EC')
      end
    end

    context 'The client is not active in any cases EC/FC/KC' do
      context 'The client is active in only one program' do
        let!(:leave_program) { create(:leave_program, client_enrollment: first_client_enrollment, program_stream: first_program_stream) }
        it 'status should remain Referred' do
          expect(client.status).to eq('Referred')
        end
      end

      context 'The client is active in more than one program' do
        let!(:leave_program) { create(:leave_program, client_enrollment: second_client_enrollment, program_stream: second_program_stream) }
        it 'status should remain Active' do
          client.reload
          expect(client.status).to eq('Active')
        end
      end
    end
  end
end
