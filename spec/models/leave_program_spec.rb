describe LeaveProgram do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  describe LeaveProgram, 'associations' do
    it { is_expected.to belong_to(:enrollment) }
    it { is_expected.to belong_to(:client_enrollment) }
    it { is_expected.to belong_to(:program_stream) }
    it { is_expected.to have_many(:form_builder_attachments).dependent(:destroy)  }
    it { is_expected.to accept_nested_attributes_for(:form_builder_attachments) }
  end

  describe LeaveProgram, 'validations' do
    it { is_expected.to validate_presence_of(:exit_date) }

    let!(:client) { create(:client) }
    let!(:program_stream) { create(:program_stream)}
    let!(:family) { create(:family, :inactive) }
    let!(:entity_program_stream) { create(:program_stream, :attached_with_family)}
    let!(:community) { create(:community) }
    let!(:community_program_stream) { create(:program_stream, :attached_with_community)}

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

    context 'exit_date_value of client' do
      it 'should be any date after program enrollment date' do
        properties = {"e-mail"=>"test@example.com", "age"=>"6", "description"=>"this is testing"}
        client_enrollment = ClientEnrollment.create(program_stream: program_stream, client: client, properties: properties, enrollment_date: '2017-06-08')
        leave_program = LeaveProgram.new(client_enrollment: client_enrollment, program_stream: program_stream, properties: properties, exit_date: '2017-06-07')
        leave_program.save
        expect(leave_program.errors[:exit_date]).to include('The exit date you have selected is invalid. Please select a date after your program enrollment date.')
      end
    end

    context 'exit_date_value of entity Family' do
      it 'should be any date after program enrollment date' do
        properties = {"e-mail"=>"test@example.com", "age"=>"5", "description"=>"this is testing"}
        enrollment = FactoryBot.create(:enrollment, program_stream: entity_program_stream, programmable: family, properties: properties, enrollment_date: '2017-06-08')
        leave_program = FactoryBot.build(:leave_program, enrollment: enrollment, program_stream: entity_program_stream, properties: properties, exit_date: '2017-06-07')
        leave_program.save
        expect(leave_program.errors[:exit_date]).to include('The exit date you have selected is invalid. Please select a date after your program enrollment date.')
      end
    end

    context 'exit_date_value of entity Community' do
      it 'should be any date after program enrollment date' do
        properties = {"e-mail"=>"test@example.com", "age"=>"5", "description"=>"this is testing"}
        enrollment = FactoryBot.create(:enrollment, program_stream: community_program_stream, programmable: community, properties: properties, enrollment_date: '2017-06-08')
        leave_program = FactoryBot.build(:leave_program, enrollment: enrollment, program_stream: community_program_stream, properties: properties, exit_date: '2017-06-07')
        leave_program.save
        expect(leave_program.errors[:exit_date]).to include('The exit date you have selected is invalid. Please select a date after your program enrollment date.')
      end
    end
  end

  describe ClientEnrollment, 'scopes' do
    let!(:client) { create(:client) }
    let!(:client_other) { create(:client) }
    let!(:program_stream) { create(:program_stream) }
    let!(:client_enrollment) { create(:client_enrollment, program_stream: program_stream, client: client, status: 'Active')}
    let!(:client_enrollment_other) { create(:client_enrollment, program_stream: program_stream, client: client_other, status: 'Active')}
    let!(:leave_program) { create(:leave_program, program_stream: program_stream, client_enrollment: client_enrollment) }
    let!(:leave_program_other) { create(:leave_program, program_stream: program_stream, client_enrollment: client_enrollment_other) }

    context 'find_by_program_stream_id' do
      subject{ LeaveProgram.find_by_program_stream_id(program_stream.id) }
      it 'return leave programs with client and program_stream' do
        is_expected.to include(leave_program, leave_program_other)
      end
    end
  end

  describe LeaveProgram, 'callbacks' do
    before do
      LeaveProgramHistory.destroy_all
    end
    let!(:ec_client) { create(:client, status: 'Accepted') }
    let!(:client) { create(:client, status: 'Accepted') }
    let!(:ec_case) { create(:case, :emergency, client: ec_client) }
    let!(:first_program_stream) { create(:program_stream) }
    let!(:second_program_stream) { create(:program_stream) }
    let!(:third_program_stream) { create(:program_stream) }
    let!(:client_enrollment) { create(:client_enrollment, client: ec_client, program_stream: first_program_stream) }
    let!(:first_client_enrollment) { create(:client_enrollment, client: client, program_stream: first_program_stream) }
    let!(:second_client_enrollment) { create(:client_enrollment, client: client, program_stream: second_program_stream) }
    let!(:third_client_enrollment) { create(:client_enrollment, client: client, program_stream: third_program_stream) }
    let!(:leave_program_1) { create(:leave_program) }

    let!(:family) { create(:family, :inactive) }
    let!(:program_stream) { create(:program_stream, :attached_with_family) }
    let!(:enrollment) { create(:enrollment, program_stream: program_stream, programmable: family) }

    let!(:community) { create(:community) }
    let!(:community_program_stream) { create(:program_stream, :attached_with_community) }
    let!(:community_enrollment) { create(:enrollment, program_stream: community_program_stream, programmable: community) }

    context 'after_create' do
      context 'set_entity_status' do
        context 'The client is not active in any cases EC/FC/KC' do
          context 'The client is active in only one program' do
            let!(:leave_program) { create(:leave_program, client_enrollment: first_client_enrollment, program_stream: first_program_stream) }
            it 'status should remain Accepted' do
              expect(client.status).to eq('Accepted')
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

        context 'if Family entity is not active in other enrollments' do
          let!(:leave_program) { create(:leave_program, enrollment: enrollment, program_stream: program_stream) }
          it 'status should be Accepted' do
            expect(family.status).to eq('Accepted')
          end
        end

        context 'if Family entity is still active in other enrollments' do
          let!(:program_stream_two) { create(:program_stream, :attached_with_family) }
          let!(:enrollment_two) { create(:enrollment, program_stream: program_stream_two, programmable: family) }
          let!(:leave_program) { create(:leave_program, enrollment: enrollment, program_stream: program_stream) }
          it 'status should remain Active' do
            family.reload
            expect(family.status).to eq('Active')
          end
        end

        context 'if Community entity is not active in other enrollments' do
          let!(:leave_program) { create(:leave_program, enrollment: community_enrollment, program_stream: community_program_stream) }
          it 'status should be accepted' do
            expect(community.status).to eq('accepted')
          end
        end

        context 'if Community entity is still active in other enrollments' do
          let!(:program_stream_two) { create(:program_stream, :attached_with_community) }
          let!(:enrollment_two) { create(:enrollment, program_stream: program_stream_two, programmable: community) }
          let!(:leave_program) { create(:leave_program, enrollment: community_enrollment, program_stream: community_program_stream) }
          it 'status should remain active' do
            community.reload
            expect(community.status).to eq('active')
          end
        end
      end

      context 'update_enrollment_status of client' do
        let!(:leave_program) { create(:leave_program, client_enrollment: first_client_enrollment, program_stream: first_program_stream) }
        it 'set enrollment status to Exited' do
          expect(first_client_enrollment.status).to eq('Exited')
        end
      end

      context 'update_enrollment_status of Family entity' do
        let!(:leave_program) { create(:leave_program, enrollment: enrollment, program_stream: program_stream) }
        it 'set enrollment status to Exited' do
          expect(enrollment.status).to eq('Exited')
        end
      end

      context 'update_enrollment_status of Community entity' do
        let!(:leave_program) { create(:leave_program, enrollment: community_enrollment, program_stream: community_program_stream) }
        it 'set enrollment status to Exited' do
          expect(community_enrollment.status).to eq('Exited')
        end
      end
    end

    xcontext 'after_save' do
      context 'create_leave_program_history' do
        it 'has 1 leave program history with the same attributes' do
          expect(LeaveProgramHistory.where({'object.id' => leave_program_1.id}).count).to eq(1)
          expect(LeaveProgramHistory.where({'object.id' => leave_program_1.id}).first.object['exit_date']).to eq(leave_program_1.exit_date)
          expect(LeaveProgramHistory.where({'object.id' => leave_program_1.id}).first.object['client_enrollment_id']).to eq(leave_program_1.client_enrollment_id)
          expect(LeaveProgramHistory.where({'object.id' => leave_program_1.id}).first.object['program_stream_id']).to eq(leave_program_1.program_stream_id)
          expect(LeaveProgramHistory.where({'object.id' => leave_program_1.id}).first.object['properties']).to eq(leave_program_1.properties)
        end
        it 'update leave program should create another leave program history' do
          leave_program_1.update(updated_at: Date.today)
          expect(LeaveProgramHistory.where('$and' =>[{'object.id' => leave_program_1.id}, {'object.updated_at' => Date.today}]).count).to eq(1)
        end
      end
    end
  end
end
