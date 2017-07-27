describe ClientEnrollment, 'associations' do
  it { is_expected.to belong_to(:client) }
  it { is_expected.to belong_to(:program_stream) }
  it { is_expected.to have_many(:client_enrollment_trackings).dependent(:destroy) }
  it { is_expected.to have_many(:trackings).through(:client_enrollment_trackings) }
  it { is_expected.to have_one(:leave_program).dependent(:destroy) }
end

describe ClientEnrollment, 'validations' do
  it { is_expected.to validate_presence_of(:enrollment_date) }

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

describe ClientEnrollment, 'scopes' do
  let!(:client) { create(:client) }
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client)}
  
  context 'enrollments_by' do
    subject{ ClientEnrollment.enrollments_by(client) }
    it 'return client enrollments with client and program_stream' do
      is_expected.to include(client_enrollment)
    end
  end

  context 'active' do
    let!(:exited_client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client, status: 'Exited') }

    subject{ ClientEnrollment.active }
    it 'should return client enrollment with active status' do
      is_expected.to include(client_enrollment)
    end

    it 'should return client enrollment with exited status' do
      is_expected.not_to include(exited_client_enrollment) 
    end
  end
end

describe ClientEnrollment, 'callbacks' do
  let!(:program_stream) { create(:program_stream) }
  let!(:client) { create(:client) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client) }

  context 'set_client_status' do
    it 'return client status active when not in any case' do
      expect(client_enrollment.client.status).to eq("Referred")
      client_enrollment.reload
      client_enrollment.update(enrollment_date: FFaker::Time.date)
      expect(client_enrollment.client.status).to eq("Active")
    end

    it 'return client status active when in case EC' do
      case_client = FactoryGirl.create(:case, client: client)
      case_client_enrollment = FactoryGirl.create(:client_enrollment, program_stream: program_stream, client: client)
      expect(case_client_enrollment.client.status).to eq("Active EC")
      case_client_enrollment.reload
      case_client_enrollment.update(enrollment_date: FFaker::Time.date)
      expect(case_client_enrollment.client.status).to eq("Active")
    end
  end
end

describe ClientEnrollment, 'methods' do
  context 'has_client_enrollment_tracking?' do
    let!(:client) { create(:client) }
    let!(:program_stream) { create(:program_stream) }
    let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client)}

    it 'return true' do
      ClientEnrollmentTracking.create(client_enrollment: client_enrollment)
      expect(client_enrollment.has_client_enrollment_tracking?).to be true
    end

    it 'return false' do
      expect(client_enrollment.has_client_enrollment_tracking?).to be false
    end
  end
end