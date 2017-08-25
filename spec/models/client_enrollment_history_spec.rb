describe ClientEnrollmentHistory, 'class method' do
  before do
    ClientEnrollmentHistory.destroy_all
  end

  context 'initial(client_enrollment)' do
    let!(:client_enrollment){ create(:client_enrollment) }
    it { expect(ClientEnrollmentHistory.count).to eq(1) }
    it { expect(ClientEnrollmentHistory.first.object['id']).to eq(client_enrollment.id) }
    it { expect(ClientEnrollmentHistory.first.object['properties']).to eq(client_enrollment.properties) }
  end
end
