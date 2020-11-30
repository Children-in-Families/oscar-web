describe EnrollmentTracking do
  describe EnrollmentTracking, 'associations' do
    it { is_expected.to belong_to(:enrollment) }
    it { is_expected.to belong_to(:tracking) }
    it { is_expected.to have_many(:form_builder_attachments).dependent(:destroy)  }
    it { is_expected.to accept_nested_attributes_for(:form_builder_attachments) }
  end

  describe EnrollmentTracking, 'scope' do
    let!(:program_stream) { create(:program_stream, :attached_with_family) }
    let!(:enrollment) { create(:enrollment, program_stream: program_stream) }
    let!(:tracking) { create(:tracking, program_stream: program_stream) }
    let!(:second_tracking) { create(:tracking, program_stream: program_stream) }
    let!(:first_enrollment_tracking) { create(:enrollment_tracking, tracking: tracking, enrollment: enrollment) }
    let!(:second_enrollment_tracking) { create(:enrollment_tracking, tracking: tracking, enrollment: enrollment) }
    let!(:third_enrollment_tracking) { create(:enrollment_tracking, tracking: second_tracking, enrollment: enrollment) }

    context 'ordered' do
      it 'return first record of enrollment_tracking' do
        expect(EnrollmentTracking.ordered.first).to eq first_enrollment_tracking
      end

      xit 'return second record of enrollment_tracking' do
        expect(EnrollmentTracking.ordered.last).to eq second_enrollment_tracking
      end
    end

    context 'enrollment_trackings_by' do
      it 'return records by tracking' do
        expect(EnrollmentTracking.enrollment_trackings_by(tracking)).to include(first_enrollment_tracking, second_enrollment_tracking)
        expect(EnrollmentTracking.enrollment_trackings_by(tracking)).not_to include(second_tracking)
      end
    end
  end

  describe EnrollmentTracking, 'validations' do
    let!(:program_stream) { create(:program_stream, :attached_with_family) }
    let!(:enrollment) { create(:enrollment, program_stream: program_stream) }
    let!(:tracking) { create(:tracking, program_stream: program_stream) }

    context 'custom form email validator' do
      it 'return its not an email' do
        properties = {"e-mail"=>"cifcambodianfamily", "age"=>"3", "description"=>"this is testing"}
        enrollment_tracking = EnrollmentTracking.new(properties: properties, tracking: tracking, enrollment: enrollment)
        enrollment_tracking.save
        expect(enrollment_tracking.errors.full_messages).to include("E-mail is not an email")
      end
    end

    context 'custom form presence validator' do
      it 'return cant be blank' do
        properties = {"e-mail"=>"cifcambodianfamily", "age"=>"3", "description"=>""}
        enrollment_tracking = EnrollmentTracking.new(properties: properties, tracking: tracking, enrollment: enrollment)
        enrollment_tracking.save
        expect(enrollment_tracking.errors.full_messages).to include("Description can't be blank")
      end
    end

    context 'custom form number validator' do
      it 'return cant be greater' do
        properties = {"e-mail"=>"test@example.com", "age"=>"6", "description"=>"this is testing"}
        enrollment_tracking = EnrollmentTracking.new(properties: properties, tracking: tracking, enrollment: enrollment)
        enrollment_tracking.save
        expect(enrollment_tracking.errors.full_messages).to include("Age can't be greater than 5")
      end

      it 'return cant be lower' do
        properties = {"e-mail"=>"test@example.com", "age"=>"0", "description"=>"this is testing"}
        enrollment_tracking = EnrollmentTracking.new(properties: properties, tracking: tracking, enrollment: enrollment)
        enrollment_tracking.save
        expect(enrollment_tracking.errors.full_messages).to include("Age can't be lower than 1")
      end
    end
  end

  xdescribe EnrollmentTracking, 'callbacks' do
    before do
      EntityEnrollmentTrackingHistory.destroy_all
    end

    context 'after_save' do
      let!(:enrollment_tracking_1) { create(:enrollment_tracking) }

      context 'after_save' do
        context 'create_enrollment_tracking_history' do
          it 'has 1 entity enrollment tracking history with the same attributes' do
            expect(EntityEnrollmentTrackingHistory.where({'object.id' => enrollment_tracking_1.id}).count).to eq(1)
            expect(EntityEnrollmentTrackingHistory.where({'object.id' => enrollment_tracking_1.id}).first.object['enrollment_id']).to eq(enrollment_tracking_1.enrollment_id)
            expect(EntityEnrollmentTrackingHistory.where({'object.id' => enrollment_tracking_1.id}).first.object['properties']).to eq(enrollment_tracking_1.properties)
          end
          it 'update entity enrollment tracking should create another entity enrollment tracking history' do
            enrollment_tracking_1.update(updated_at: Date.today)
            expect(EntityEnrollmentTrackingHistory.where('$and' =>[{'object.id' => enrollment_tracking_1.id}, {'object.updated_at' => Date.today}]).count).to eq(1)
          end
        end
      end
    end
  end
end
