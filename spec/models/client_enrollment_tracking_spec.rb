describe ClientEnrollmentTracking, 'associations' do
  it { is_expected.to belong_to(:client_enrollment) }
  it { is_expected.to belong_to(:tracking) }
end

describe ClientEnrollmentTracking, 'scope' do
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream) }
  let!(:tracking) { create(:tracking, program_stream: program_stream) }
  let!(:first_client_enrollment_tracking) { create(:client_enrollment_tracking, tracking: tracking, client_enrollment: client_enrollment) }
  let!(:second_client_enrollment_tracking) { create(:client_enrollment_tracking, tracking: tracking, client_enrollment: client_enrollment) }

  context 'ordered' do
    it 'return first record of client_enrollment_tracking' do
      expect(ClientEnrollmentTracking.ordered.first).to eq first_client_enrollment_tracking
    end

    it 'return second record of client_enrollment_tracking' do
      expect(ClientEnrollmentTracking.ordered.last).to eq second_client_enrollment_tracking
    end
  end
end

describe ClientEnrollmentTracking, 'validations' do
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream) }
  let!(:tracking) { create(:tracking, program_stream: program_stream) }

  context 'custom form email validator' do
    it 'return its not an email' do
      properties = {"e-mail"=>"cifcambodianfamily", "age"=>"3", "description"=>"this is testing"}
      client_enrollment_tracking = ClientEnrollmentTracking.new(properties: properties, tracking: tracking, client_enrollment: client_enrollment)
      client_enrollment_tracking.save
      expect(client_enrollment_tracking.errors.full_messages).to include("E-mail is not an email")
    end
  end

  context 'custom form presence validator' do
    it 'return cant be blank' do
      properties = {"e-mail"=>"cifcambodianfamily", "age"=>"3", "description"=>""}
      client_enrollment_tracking = ClientEnrollmentTracking.new(properties: properties, tracking: tracking, client_enrollment: client_enrollment)
      client_enrollment_tracking.save
      expect(client_enrollment_tracking.errors.full_messages).to include("Description can't be blank")
    end
  end

  context 'custom form number validator' do
    it 'return cant be greater' do
      properties = {"e-mail"=>"test@example.com", "age"=>"6", "description"=>"this is testing"}
      client_enrollment_tracking = ClientEnrollmentTracking.new(properties: properties, tracking: tracking, client_enrollment: client_enrollment)
      client_enrollment_tracking.save
      expect(client_enrollment_tracking.errors.full_messages).to include("Age can't be greater than 5")
    end 

    it 'return cant be lower' do
      properties = {"e-mail"=>"test@example.com", "age"=>"0", "description"=>"this is testing"}
      client_enrollment_tracking = ClientEnrollmentTracking.new(properties: properties, tracking: tracking, client_enrollment: client_enrollment)
      client_enrollment_tracking.save
      expect(client_enrollment_tracking.errors.full_messages).to include("Age can't be lower than 1")
    end 
  end
end