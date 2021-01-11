describe EntityEnrollmentHistory, 'class method' do
  before do
    EntityEnrollmentHistory.destroy_all
  end

  describe EntityEnrollmentHistory, 'methods' do
    context '#format_property' do
      let!(:enrollment){ create(:enrollment_with_history) }
      it 'saves properties values to EntityEnrollmentHistory' do
        expect(enrollment.properties).to eq(EntityEnrollmentHistory.first.object[:properties])
      end
    end
  end
end
