describe Enrollment do
  describe Enrollment, 'associations' do
    it { is_expected.to belong_to(:programmable) }
    it { is_expected.to belong_to(:program_stream) }
    it { is_expected.to have_many(:enrollment_trackings).dependent(:destroy) }
    it { is_expected.to have_many(:trackings).through(:enrollment_trackings) }
    it { is_expected.to have_one(:leave_program).dependent(:destroy) }
    it { is_expected.to have_many(:form_builder_attachments).dependent(:destroy)  }
    it { is_expected.to accept_nested_attributes_for(:form_builder_attachments) }
  end

  describe Enrollment, 'validations' do
    it { is_expected.to validate_presence_of(:enrollment_date) }

    let!(:family) { create(:family, :inactive) }
    let!(:program_stream) { create(:program_stream, :attached_with_family)}

    context 'custom form email validator' do
      it 'return is not an email' do
        properties = {"e-mail"=>"cifcambodianfamily", "age"=>"3", "description"=>"this is testing"}
        enrollment = Enrollment.new(program_stream: program_stream, programmable: family, properties: properties)
        enrollment.save
        expect(enrollment.errors.full_messages).to include("E-mail is not an email")
      end
    end

    context 'custom form present validator' do
      it 'return cant be blank' do
        properties = {"e-mail"=>"test@example.com", "age"=>"3", "description"=>""}
        enrollment = Enrollment.new(program_stream: program_stream, programmable: family, properties: properties)
        enrollment.save
        expect(enrollment.errors.full_messages).to include("Description can't be blank")
      end
    end

    context 'custom form number validator' do
      it 'return cant be greater' do
        properties = {"e-mail"=>"test@example.com", "age"=>"6", "description"=>"this is testing"}
        enrollment = Enrollment.new(program_stream: program_stream, programmable: family, properties: properties)
        enrollment.save
        expect(enrollment.errors.full_messages).to include("Age can't be greater than 5")
      end

      it 'return cant be lower' do
        properties = {"e-mail"=>"test@example.com", "age"=>"0", "description"=>"this is testing"}
        enrollment = Enrollment.new(program_stream: program_stream, programmable: family, properties: properties)
        enrollment.save
        expect(enrollment.errors.full_messages).to include("Age can't be lower than 1")
      end
    end

    context 'enrollment_date_value' do
      it 'should be any date before the program exit date' do
        properties = {"e-mail"=>"test@example.com", "age"=>"3", "description"=>"this is testing"}
        enrollment = FactoryGirl.create(:enrollment, program_stream: program_stream, programmable: family, properties: properties, enrollment_date: '2017-06-08')
        leave_program = FactoryGirl.create(:leave_program, enrollment: enrollment, program_stream: program_stream, properties: properties, exit_date: '2017-06-09')
        enrollment.enrollment_date = '2017-06-10'
        enrollment.save
        expect(enrollment.errors[:enrollment_date]).to include('The enrollment date you have selected is invalid. Please select a date prior to your program exit date.')
      end
    end
  end

  describe Enrollment, 'scopes' do
    let!(:family) { create(:family, :inactive) }
    let!(:program_stream) { create(:program_stream, :attached_with_family) }
    let!(:active_enrollment) { create(:enrollment, program_stream: program_stream, programmable: family)}
    let!(:inactive_enrollment) { create(:enrollment, program_stream: program_stream, programmable: family, status: 'Exited') }
    let!(:community){ create(:community) }
    let!(:community_program_stream) { create(:program_stream, :attached_with_community) }
    let!(:community_enrollment) { create(:enrollment, program_stream: community_program_stream, programmable: community)}

    context 'enrollments_by' do
      subject{ Enrollment.enrollments_by(family) }
      it 'return family enrollments with family and program_stream' do
        is_expected.to include(active_enrollment)
      end
    end

    context 'find_by' do
      subject{ Enrollment.find_by_program_stream_id(program_stream.id) }
      it 'return family enrollments that used this program_stream' do
        is_expected.to include(active_enrollment, inactive_enrollment)
      end
    end

    context 'active' do
      subject{ Enrollment.active }
      it 'should return family enrollment with active status' do
        is_expected.to include(active_enrollment)
      end

      it 'should return family enrollment with exited status' do
        is_expected.not_to include(inactive_enrollment)
      end
    end

    context 'attached_with' do
      it 'return records attached with corresponding entity' do
        expect(Enrollment.attached_with('Family')).to include(active_enrollment)
        expect(Enrollment.attached_with('Community')).to include(community_enrollment)

        expect(Enrollment.attached_with('Family')).not_to include(community_enrollment)
        expect(Enrollment.attached_with('Community')).not_to include(active_enrollment)
      end
    end


    # context 'inactive' do
    #   subject{ Enrollment.inactive }
    #   it 'should return inactive family enrollments' do
    #     is_expected.to include(inactive_enrollment)
    #   end
    #   it 'should not return active family enrollments' do
    #     is_expected.not_to include(active_enrollment)
    #   end
    # end
  end

  describe Enrollment, 'callbacks' do
    let!(:program_stream) { create(:program_stream) }
    let!(:other_program_stream) { create(:program_stream) }
    let!(:family) { create(:family, :inactive) }
    let!(:enrollment) { create(:enrollment, program_stream: program_stream, programmable: family) }
    let!(:other_enrollment) { create(:enrollment, program_stream: other_program_stream, programmable: family) }

    context 'after_save' do
      xcontext 'create_enrollment_history' do
        before do
          EnrollmentHistory.destroy_all
        end
        it 'has 1 family enrollment history with the same attributes' do
          expect(EnrollmentHistory.where({'object.id' => enrollment.id}).count).to eq(1)
          expect(EnrollmentHistory.where({'object.id' => enrollment.id}).first.object['enrollment_date']).to eq(enrollment.enrollment_date)
          expect(EnrollmentHistory.where({'object.id' => enrollment.id}).first.object['status']).to eq(enrollment.status)
          expect(EnrollmentHistory.where({'object.id' => enrollment.id}).first.object['program_stream_id']).to eq(enrollment.program_stream_id)
          expect(EnrollmentHistory.where({'object.id' => enrollment.id}).first.object['properties']).to eq(enrollment.properties)
        end
        it 'update family enrollment should create another family enrollment history' do
          enrollment.update(created_at: Date.today)
          expect(EnrollmentHistory.where('$and' =>[{'object.id' => enrollment.id}, {'object.created_at' => Date.today}]).count).to eq(1)
        end
      end
    end

    context 'after_create' do
      context 'set_entity_status' do
        it 'return family status active' do
          expect(enrollment.programmable.status).to eq("Active")
        end
      end
    end

    context 'after_destroy' do
      context 'reset_entity_status' do
        it 'return family status active when still actively enrolled in other programs' do
          family.reload
          other_enrollment.destroy
          expect(family.status).to eq('Active')
        end

        it 'return family status Accepted when not active in any cases or programs' do
          enrollment.destroy
          other_enrollment.destroy
          expect(family.status).to eq('Accepted')
        end
      end
    end
  end

  describe Enrollment, 'methods' do
    let!(:family) { create(:family, :inactive) }
    let!(:program_stream) { create(:program_stream) }
    let!(:enrollment) { create(:enrollment, program_stream: program_stream, programmable: family, enrollment_date: '2017-11-01')}

    context 'has_enrollment_tracking?' do
      it 'return true' do
        EnrollmentTracking.create(enrollment: enrollment)
        expect(enrollment.has_enrollment_tracking?).to be true
      end

      it 'return false' do
        expect(enrollment.has_enrollment_tracking?).to be false
      end
    end

    context 'active?' do
      it 'returns true if status is active' do
        expect(enrollment.active?).to be true
      end
    end

    # context 'short_enrollment_date' do
    #   it 'returns the end of month of the enrollment date formatted only month and year' do
    #     expect(enrollment.short_enrollment_date).to eq('Nov-17')
    #   end
    # end
  end
end
