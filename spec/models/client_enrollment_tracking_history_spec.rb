describe ClientEnrollmentTrackingHistory, 'class methods' do
  before do
    ClientEnrollmentTrackingHistory.destroy_all
  end

  context 'initial(client_enrollment_tracking)' do
    let!(:client_enrollment_tracking){ create(:client_enrollment_tracking) }
    it { expect(ClientEnrollmentTrackingHistory.count).to eq(1) }
    it { expect(ClientEnrollmentTrackingHistory.first.object['id']).to eq(client_enrollment_tracking.id) }
    it { expect(ClientEnrollmentTrackingHistory.first.object['properties']).to eq(client_enrollment_tracking.properties) }
  end
end
