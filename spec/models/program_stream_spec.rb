describe ProgramStream do
  before do
    allow_any_instance_of(Client).to receive(:generate_random_char).and_return("abcd")
  end
  describe ProgramStream, 'associations' do
    it { is_expected.to have_many(:domain_program_streams).dependent(:destroy) }
    it { is_expected.to have_many(:domains).through(:domain_program_streams) }
    it { is_expected.to have_many(:client_enrollments).dependent(:destroy) }
    it { is_expected.to have_many(:clients).through(:client_enrollments) }
    it { is_expected.to have_many(:trackings).dependent(:destroy) }
    it { is_expected.to have_many(:leave_programs).dependent(:destroy) }
    it { is_expected.to have_many(:program_stream_permissions).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:program_stream_permissions) }
    it { is_expected.to have_many(:program_stream_services).dependent(:destroy) }
    it { is_expected.to have_many(:services).through(:program_stream_services) }
    it { is_expected.to have_many(:enrollments).dependent(:destroy) }
    it { is_expected.to have_many(:families).through(:enrollments).source(:programmable) }
  end

  describe ProgramStream, 'scope' do
    let!(:family_program_stream)  { create(:program_stream, :attached_with_family, name: 'efg') }
    let!(:first_program_stream)  { create(:program_stream, name: 'def') }
    let!(:second_program_stream) { create(:program_stream, name: 'abc') }
    let!(:third_program_stream)  { create(:program_stream, name: 'abcf', mutual_dependence: [second_program_stream.id, first_program_stream.id]) }

    context 'attached_with' do
      it 'return records attached with corresponding entity' do
        expect(ProgramStream.attached_with('Client')).to include(first_program_stream, second_program_stream, third_program_stream)
        expect(ProgramStream.attached_with('Client')).not_to include(family_program_stream)

        expect(ProgramStream.attached_with('Family')).to include(family_program_stream)
        expect(ProgramStream.attached_with('Family')).not_to include(first_program_stream, second_program_stream, third_program_stream)
      end
    end

    context 'ordered' do
      it 'return the correct order of name' do
        expect(ProgramStream.ordered).to eq [second_program_stream, third_program_stream, first_program_stream, family_program_stream]
      end
    end

    context 'ordered_by' do
      it 'order the record of the given column' do
        expect(ProgramStream.ordered_by('name ASC').first).to eq second_program_stream
      end
    end

    context 'completed' do
      let!(:tracking) { create(:tracking, program_stream: first_program_stream) }
      it 'return record that is completed' do
        first_program_stream.reload
        first_program_stream.update(name: FFaker::Name.name)
        expect(ProgramStream.complete.first).to eq first_program_stream
      end
    end

    context 'filter program streams' do
      it 'return records of programs' do
        expect(ProgramStream.filter(third_program_stream.mutual_dependence)).to include(first_program_stream, second_program_stream)
      end
    end

    context 'name_like' do
      it 'return program streams name like' do
        expect(ProgramStream.name_like(['def', 'abc'])).to include(first_program_stream, second_program_stream)
      end
    end

    context 'by_name' do
      it 'return program streams by name' do
        expect(ProgramStream.by_name('a')).to include(second_program_stream, third_program_stream)
        expect(ProgramStream.by_name('a')).not_to include(first_program_stream)
      end
    end

    context 'deletion' do
      it 'should soft delete' do
        first_program_stream.destroy
        expect(ProgramStream.with_deleted.find(first_program_stream.id)).to eq first_program_stream
      end

      it 'should really delete' do
        first_program_stream.destroy_fully!
        expect { ProgramStream.with_deleted.find(first_program_stream.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe ProgramStream, 'callback' do
    context 'before_save' do
      let!(:program_1){ create(:program_stream, tracking_required: false) }
      let!(:program_2){ create(:program_stream, tracking_required: true) }
      context '#set_program_completed' do
        it 'true as Completed' do
          expect(program_2.completed).to be_truthy
        end

        it 'false as Incomplete' do
          expect(program_1.completed).to be_falsey
        end
      end
    end

    context 'valid' do
      let!(:completed_program_stream) { create(:program_stream)}
      let!(:tracking) { create(:tracking, program_stream: completed_program_stream) }

      it 'return completed field equal true' do
        completed_program_stream.reload
        completed_program_stream.update(name: FFaker::Name.name)
        expect(completed_program_stream.completed).to be true
      end
    end

    context 'invalid' do
      let!(:program_stream) { create(:program_stream)}

      it 'return completed field equal false' do
        expect(program_stream.completed).to be false
      end
    end

    context 'build permission' do
      let!(:program_stream) { create(:program_stream) }
      let!(:user) { create(:user) }

      it 'create records in program stream permission' do
        expect(user.program_stream_permissions.first.user_id).to eq(user.id)
        expect(user.program_stream_permissions.first.program_stream_id).to eq(program_stream.id)
        expect(user.program_stream_permissions.first.readable).to eq(true)
        expect(user.program_stream_permissions.first.editable).to eq(true)
      end
    end
  end

  describe ProgramStream, 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to accept_nested_attributes_for(:trackings) }
  end

  describe ProgramStream, 'uniqueness enrollment tracking and exit_program' do
    rules         = {'rules'=>[{'id'=>'age', 'type'=>'integer', 'field'=>'age', 'input'=>'text', 'value'=>'2', 'operator'=>'equal'}], 'condition'=>'AND'}.to_json
    enrollment    = [{'label'=>'hello','type'=>'text'}, {'label'=>'hello','type'=>'text'}]
    exit_program  = [{'label'=>'Mr.ABC','type'=>'text'}, {'label'=>'Mr.ABC','type'=>'text'}]
    program_stream_duplicate = ProgramStream.new(name: 'Test', rules: rules, enrollment: enrollment, exit_program: exit_program)

    it 'return errors fields duplicate' do
      program_stream_duplicate.save
      expect(program_stream_duplicate.errors.full_messages).to include("Enrollment Fields duplicated!", "Exit program Fields duplicated!")
    end
  end

  describe ProgramStream, 'validate rules edition' do
    context 'ProgramStream has rules' do
      let(:client) { create(:client, gender: 'male') }
      rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'male', 'operator'=>'equal' }], 'condition'=>'AND' }
      let(:program_stream) { create(:program_stream, rules: rules ) }
      let(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream) }

      it 'unable to save program stream' do
        wrong_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'female', 'operator'=>'equal' }, {'id'=>'status', 'type'=>'string', 'field'=>'status', 'input'=>'select', 'value'=>'Active', 'operator'=>'equal' }], 'condition'=>'AND' }
        program_stream.update(rules: wrong_rules)
        expect(program_stream.errors[:rules]).to match_array([])
      end

      it 'able to save program stream' do
        correct_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'male', 'operator'=>'equal' }, {'id'=>'status', 'type'=>'string', 'field'=>'status', 'input'=>'select', 'value'=>'Active', 'operator'=>'equal' }], 'condition'=>'AND' }
        program_stream.update(rules: correct_rules)
        expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
      end
    end

    context 'ProgramStream has no rules' do
      let!(:client) { create(:client, gender: 'male') }
      let!(:program_stream) { create(:program_stream, rules: {} ) }
      let!(:unused_program){ create(:program_stream, rules: {}) }
      let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream) }

      xit 'unable to save program stream' do
        wrong_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'female', 'operator'=>'equal' }], 'condition'=>'AND' }
        program_stream.update(rules: wrong_rules)
        expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
      end

      xit 'able to save program stream' do
        correct_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'male', 'operator'=>'equal' }], 'condition'=>'AND' }
        program_stream.update(rules: correct_rules)
        expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
      end

      it 'able to save unused program' do
        correct_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'female', 'operator'=>'equal' }], 'condition'=>'AND' }
        unused_program.rules = correct_rules
        expect(unused_program).to be_valid
      end
    end
  end

  describe ProgramStream, 'validate program edition' do
    context 'ProgramStream has no mutual dependence and program exclusive' do
      let!(:client) { create(:client, gender: 'male') }
      let!(:program_stream) { create(:program_stream) }
      let!(:program_stream_1) { create(:program_stream) }
      let!(:program_stream_2) { create(:program_stream) }
      let!(:program_stream_3) { create(:program_stream) }
      let!(:program_stream_4) { create(:program_stream) }
      let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream) }
      let!(:client_enrollment_1) { create(:client_enrollment, client: client, program_stream: program_stream_1) }
      let!(:client_enrollment_2) { create(:client_enrollment, client: client, program_stream: program_stream_3) }

      xit 'unable to save program stream program exclusive' do
        program_stream.update(program_exclusive: [program_stream_1.id])
        expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
      end

      it 'able to save program stream program exclusive' do
        program_stream.update(program_exclusive: [program_stream_2.id])
        expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
      end

      xit 'unable to save program stream with mutual dependence' do
        program_stream.update(mutual_dependence: [program_stream_4.id])
        expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
      end

      it 'able to save program stream mutual dependence' do
        program_stream.update(mutual_dependence: [program_stream_1.id])
        expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
      end
    end

    context 'ProgramStream has no mutual dependence and program exclusive with multiple select' do
      let!(:client) { create(:client, gender: 'male') }
      let!(:program_stream) { create(:program_stream) }
      let!(:program_stream_1) { create(:program_stream) }
      let!(:program_stream_2) { create(:program_stream) }
      let!(:program_stream_3) { create(:program_stream) }
      let!(:program_stream_4) { create(:program_stream) }
      let!(:program_stream_5) { create(:program_stream) }
      let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream) }
      let!(:client_enrollment_1) { create(:client_enrollment, client: client, program_stream: program_stream_1) }
      let!(:client_enrollment_2) { create(:client_enrollment, client: client, program_stream: program_stream_3) }

      xit 'unable to save program stream program exclusive' do
        program_stream.update(program_exclusive: [program_stream_1.id, program_stream_3.id])
        expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
      end

      it 'able to save program stream program exclusive' do
        program_stream.update(program_exclusive: [program_stream_2.id, program_stream_5.id])
        expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
      end

      xit 'unable to save program stream with mutual dependence' do
        program_stream.update(mutual_dependence: [program_stream_4.id, program_stream_5.id])
        expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
      end

      it 'able to save program stream mutual dependence' do
        program_stream.update(mutual_dependence: [program_stream_1.id, program_stream_3.id])
        expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
      end
    end
  end

  describe ProgramStream, 'validate program edition and rules edition' do
    context 'attached to client' do
      context 'ProgramStream has no mutual dependence and program exclusive' do
        rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'male', 'operator'=>'equal' }], 'condition'=>'AND' }
        wrong_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'female', 'operator'=>'equal' }, {'id'=>'status', 'type'=>'string', 'field'=>'status', 'input'=>'select', 'value'=>'Active', 'operator'=>'equal' }], 'condition'=>'AND' }
        let!(:client) { create(:client, gender: 'male') }
        let!(:program_stream) { create(:program_stream, rules: rules) }
        let!(:program_stream_1) { create(:program_stream) }
        let!(:program_stream_2) { create(:program_stream) }
        let!(:program_stream_3) { create(:program_stream) }
        let!(:program_stream_4) { create(:program_stream) }
        let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream) }
        let!(:client_enrollment_1) { create(:client_enrollment, client: client, program_stream: program_stream_1) }
        let!(:client_enrollment_2) { create(:client_enrollment, client: client, program_stream: program_stream_3) }

        xit 'unable to save program stream program exclusive and rules' do
          program_stream.update(program_exclusive: [program_stream_1.id], rules: wrong_rules)
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
        end

        it 'able to save program stream program exclusive and rules' do
          program_stream.update(program_exclusive: [program_stream_2.id], rules: rules)
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
        end

        xit 'unable to save program mutual dependence and rules' do
          program_stream.update(rules: wrong_rules, mutual_dependence: [program_stream_4.id])
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream mutual dependence and rules' do
          program_stream.update(rules: rules, mutual_dependence: [program_stream_1.id])
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        xit 'unable to save program stream program exclusive and mutual dependence' do
          program_stream.update(program_exclusive: [program_stream_1.id], mutual_dependence: [program_stream_4.id])
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream program exclusive and mutual dependence' do
          program_stream.update(program_exclusive: [program_stream_2.id], mutual_dependence: [program_stream_1.id])
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        xit 'unable to save program stream program exclusive, mutual dependence and rules' do
          program_stream.update(program_exclusive: [program_stream_1.id], rules: wrong_rules, mutual_dependence: [program_stream_4.id])
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream program exclusive, mutual dependence and rules' do
          program_stream.update(program_exclusive: [program_stream_2.id], rules: rules, mutual_dependence: [program_stream_1.id])
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end
      end

      context 'ProgramStream has no mutual dependence and program exclusive with multiple select' do
        rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'male', 'operator'=>'equal' }], 'condition'=>'AND' }
        wrong_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'female', 'operator'=>'equal' }, {'id'=>'status', 'type'=>'string', 'field'=>'status', 'input'=>'select', 'value'=>'Active', 'operator'=>'equal' }], 'condition'=>'AND' }
        let!(:client) { create(:client, gender: 'male') }
        let!(:program_stream) { create(:program_stream, rules: rules) }
        let!(:program_stream_1) { create(:program_stream) }
        let!(:program_stream_2) { create(:program_stream) }
        let!(:program_stream_3) { create(:program_stream) }
        let!(:program_stream_4) { create(:program_stream) }
        let!(:program_stream_5) { create(:program_stream) }
        let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream) }
        let!(:client_enrollment_1) { create(:client_enrollment, client: client, program_stream: program_stream_1) }
        let!(:client_enrollment_2) { create(:client_enrollment, client: client, program_stream: program_stream_3) }

        xit 'unable to save program stream program exclusive and rules' do
          program_stream.update(program_exclusive: [program_stream_1.id, program_stream_3.id], rules: wrong_rules)
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
        end

        it 'able to save program stream program exclusive and rules' do
          program_stream.update(program_exclusive: [program_stream_2.id, program_stream_5.id], rules: rules)
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
        end

        xit 'unable to save program mutual dependence and rules' do
          program_stream.update(rules: wrong_rules, mutual_dependence: [program_stream_4.id, program_stream_5.id])
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream mutual dependence and rules' do
          program_stream.update(rules: rules, mutual_dependence: [program_stream_1.id, program_stream_3.id])
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        xit 'unable to save program stream program exclusive and mutual dependence' do
          program_stream.update(program_exclusive: [program_stream_1.id, program_stream_3.id], mutual_dependence: [program_stream_4.id, program_stream_5.id])
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream program exclusive and mutual dependence' do
          program_stream.update(program_exclusive: [program_stream_2.id, program_stream_5.id], mutual_dependence: [program_stream_1.id, program_stream_3.id])
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        xit 'unable to save program stream program exclusive, mutual dependence and rules' do
          program_stream.update(program_exclusive: [program_stream_1.id, program_stream_3.id], rules: wrong_rules, mutual_dependence: [program_stream_4.id, program_stream_5.id])
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream program exclusive, mutual dependence and rules' do
          program_stream.update(program_exclusive: [program_stream_2.id, program_stream_5.id], rules: rules, mutual_dependence: [program_stream_1.id, program_stream_3.id])
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end
      end
    end

    context 'attached to family and other entity' do
      context 'ProgramStream has no mutual dependence and program exclusive' do
        rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'male', 'operator'=>'equal' }], 'condition'=>'AND' }
        wrong_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'female', 'operator'=>'equal' }, {'id'=>'status', 'type'=>'string', 'field'=>'status', 'input'=>'select', 'value'=>'Active', 'operator'=>'equal' }], 'condition'=>'AND' }
        let!(:family) { create(:family) }
        let!(:program_stream) { create(:program_stream, :attached_with_family, rules: rules) }
        let!(:program_stream_1) { create(:program_stream, :attached_with_family) }
        let!(:program_stream_2) { create(:program_stream, :attached_with_family) }
        let!(:program_stream_3) { create(:program_stream, :attached_with_family) }
        let!(:program_stream_4) { create(:program_stream, :attached_with_family) }
        let!(:enrollment) { create(:enrollment, programmable: family, program_stream: program_stream) }
        let!(:enrollment_1) { create(:enrollment, programmable: family, program_stream: program_stream_1) }
        let!(:enrollment_2) { create(:enrollment, programmable: family, program_stream: program_stream_3) }

        xit 'unable to save program stream program exclusive and rules' do
          program_stream.update(program_exclusive: [program_stream_1.id], rules: wrong_rules)
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
        end

        it 'able to save program stream program exclusive and rules' do
          program_stream.update(program_exclusive: [program_stream_2.id], rules: rules)
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
        end

        xit 'unable to save program mutual dependence and rules' do
          program_stream.update(rules: wrong_rules, mutual_dependence: [program_stream_4.id])
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream mutual dependence and rules' do
          program_stream.update(rules: rules, mutual_dependence: [program_stream_1.id])
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        xit 'unable to save program stream program exclusive and mutual dependence' do
          program_stream.update(program_exclusive: [program_stream_1.id], mutual_dependence: [program_stream_4.id])
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream program exclusive and mutual dependence' do
          program_stream.update(program_exclusive: [program_stream_2.id], mutual_dependence: [program_stream_1.id])
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        xit 'unable to save program stream program exclusive, mutual dependence and rules' do
          program_stream.update(program_exclusive: [program_stream_1.id], rules: wrong_rules, mutual_dependence: [program_stream_4.id])
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream program exclusive, mutual dependence and rules' do
          program_stream.update(program_exclusive: [program_stream_2.id], rules: rules, mutual_dependence: [program_stream_1.id])
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end
      end

      context 'ProgramStream has no mutual dependence and program exclusive with multiple select' do
        rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'male', 'operator'=>'equal' }], 'condition'=>'AND' }
        wrong_rules = { 'rules'=>[ {'id'=>'gender', 'type'=>'string', 'field'=>'gender', 'input'=>'select', 'value'=>'female', 'operator'=>'equal' }, {'id'=>'status', 'type'=>'string', 'field'=>'status', 'input'=>'select', 'value'=>'Active', 'operator'=>'equal' }], 'condition'=>'AND' }
        let!(:family) { create(:family) }
        let!(:program_stream) { create(:program_stream, :attached_with_family, rules: rules) }
        let!(:program_stream_1) { create(:program_stream, :attached_with_family) }
        let!(:program_stream_2) { create(:program_stream, :attached_with_family) }
        let!(:program_stream_3) { create(:program_stream, :attached_with_family) }
        let!(:program_stream_4) { create(:program_stream, :attached_with_family) }
        let!(:program_stream_5) { create(:program_stream, :attached_with_family) }
        let!(:enrollment) { create(:enrollment, programmable: family, program_stream: program_stream) }
        let!(:enrollment_1) { create(:enrollment, programmable: family, program_stream: program_stream_1) }
        let!(:enrollment_2) { create(:enrollment, programmable: family, program_stream: program_stream_3) }

        xit 'unable to save program stream program exclusive and rules' do
          program_stream.update(program_exclusive: [program_stream_1.id, program_stream_3.id], rules: wrong_rules)
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
        end

        it 'able to save program stream program exclusive and rules' do
          program_stream.update(program_exclusive: [program_stream_2.id, program_stream_5.id], rules: rules)
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
        end

        xit 'unable to save program mutual dependence and rules' do
          program_stream.update(rules: wrong_rules, mutual_dependence: [program_stream_4.id, program_stream_5.id])
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream mutual dependence and rules' do
          program_stream.update(rules: rules, mutual_dependence: [program_stream_1.id, program_stream_3.id])
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        xit 'unable to save program stream program exclusive and mutual dependence' do
          program_stream.update(program_exclusive: [program_stream_1.id, program_stream_3.id], mutual_dependence: [program_stream_4.id, program_stream_5.id])
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream program exclusive and mutual dependence' do
          program_stream.update(program_exclusive: [program_stream_2.id, program_stream_5.id], mutual_dependence: [program_stream_1.id, program_stream_3.id])
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        xit 'unable to save program stream program exclusive, mutual dependence and rules' do
          program_stream.update(program_exclusive: [program_stream_1.id, program_stream_3.id], rules: wrong_rules, mutual_dependence: [program_stream_4.id, program_stream_5.id])
          expect(program_stream.errors[:rules]).to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end

        it 'able to save program stream program exclusive, mutual dependence and rules' do
          program_stream.update(program_exclusive: [program_stream_2.id, program_stream_5.id], rules: rules, mutual_dependence: [program_stream_1.id, program_stream_3.id])
          expect(program_stream.errors[:rules]).not_to include('Rules cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:program_exclusive]).not_to include('Program Exclusive cannot be changed or added because it breaks the previous rules.')
          expect(program_stream.errors[:mutual_dependence]).not_to include('Prerequisite Programs cannot be changed or added because it breaks the previous conditions.')
        end
      end
    end
  end

  describe ProgramStream, 'validate presence of label field' do
    context 'Enrollment' do
      context 'valid' do
        enrollment = [{"name"=>"date-1497520151012", "type"=>"date", "label"=>"Enrolment Date", "className"=>"calendar"}]
        valid_program_stream = FactoryGirl.build(:program_stream, name: 'Test', enrollment: enrollment)
        it { expect(valid_program_stream.valid?).to be_truthy }
      end

      context 'invalid' do
        enrollment = [{"name"=>"date-1497520151012", "type"=>"date", "label"=>"", "className"=>"calendar"}]
        invalid_program_stream = FactoryGirl.build(:program_stream, name: 'Test', enrollment: enrollment)
        invalid_program_stream.valid?
        it { expect(invalid_program_stream.errors[:enrollment]).to include("Label can't be blank") }
      end
    end

    context 'Leave Program' do
      context 'valid' do
        exit_program = [{"name"=>"date-1497520151012", "type"=>"date", "label"=>"Exit Date", "className"=>"calendar"}]
        valid_program_stream = FactoryGirl.build(:program_stream, exit_program: exit_program)
        it { expect(valid_program_stream.valid?).to be_truthy }
      end

      context 'invalid' do
        exit_program = [{"name"=>"date-1497520151012", "type"=>"date", "label"=>"", "className"=>"calendar"}]
        invalid_program_stream = FactoryGirl.build(:program_stream, exit_program: exit_program)
        invalid_program_stream.valid?
        it { expect(invalid_program_stream.errors[:exit_program]).to include("Label can't be blank") }
      end
    end
  end

  describe ProgramStream, 'methods' do
    let!(:programmable) { create(:family, :inactive) }
    let!(:active_program) { create(:program_stream, :attached_with_family, quantity: 1) }
    let!(:active_enrollment) { create(:enrollment, programmable: programmable, program_stream: active_program)}
    let!(:inactive_program) { create(:program_stream, :attached_with_family) }
    let!(:exit_enrollment) { create(:enrollment, programmable: programmable, program_stream: inactive_program, status: 'Exited')}

    let!(:client) { create(:client) }
    let!(:second_client) { create(:client) }
    let!(:program_stream) { create(:program_stream, quantity: 3) }
    let!(:program_stream_active) { create(:program_stream) }
    let!(:program_stream_inactive) { create(:program_stream) }
    let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream, status: 'Exited')}
    let!(:client_enrollments_inactive) { create(:client_enrollment, client: client, program_stream: program_stream_inactive, status: 'Exited')}
    let!(:client_enrollment_active) { create(:client_enrollment, client: client, program_stream: program_stream_active, status: 'Active')}
    let!(:second_client_enrollment) { create(:client_enrollment, client: second_client, program_stream: program_stream)}
    let!(:leave_program) { create(:leave_program, program_stream: program_stream, client_enrollment: client_enrollment) }
    let!(:tracking) { create(:tracking, program_stream: program_stream) }
    let!(:client_enrollment_tracking) { create(:client_enrollment_tracking, tracking: tracking, client_enrollment: client_enrollment) }
    field = [{"name"=>"email", "type"=>"text", "label"=>"email", "subtype"=>"email", "required"=>true, "className"=>"form-control"}, {"max"=>"5", "min"=>"1", "name"=>"age", "type"=>"number", "label"=>"age", "required"=>true, "className"=>"form-control"}, {"name"=>"description", "type"=>"text", "label"=>"description", "subtype"=>"text", "required"=>true, "className"=>"form-control"}]

    context 'number_available_for_entity' do
      it 'should return number of available enrollment for client' do
        expect(active_program.number_available_for_entity).to eq 0
      end

      it 'should return number of available enrollment for entity' do
        expect(program_stream.number_available_for_entity).to eq 2
      end
    end

    context 'attached_to_client?' do
      it 'should return true if entity type is Client' do
        expect(program_stream.attached_to_client?).to be true
      end
    end

    context 'attached_to_family?' do
      it 'should return true if entity type is Family' do
        expect(active_program.attached_to_family?).to be true
      end
    end

    context 'enroll?' do
      it 'should return true if first client enrollment is Exited or no enrollments at all' do
        expect(program_stream.enroll?(client)).to be true
      end
      it 'should return true if first entity enrollment is Exited or no enrollments at all' do
        expect(active_program.enroll?(programmable, 'Family')).to be false
      end
    end

    # legacy
    context 'last_enrollment' do
      it 'should return last record of program stream' do
        expect(program_stream.last_enrollment).to eq second_client_enrollment
      end
      it 'should not return record that not last' do
        expect(program_stream.last_enrollment).not_to eq client_enrollment
      end
    end

    context 'active_enrollments' do
      it 'return records of client enrollment' do
        expect(ProgramStream.active_enrollments(client).first).to eq program_stream_active
        expect(ProgramStream.active_enrollments(programmable, true).first).to eq active_program
      end

      it 'return records of entity enrollment' do
        expect(ProgramStream.active_enrollments(programmable, true)).to include(active_program)
        expect(ProgramStream.active_enrollments(client)).not_to include(program_stream,  program_stream_inactive)
      end
    end

    context 'inactive_enrollments' do
      it 'return records of client enrollment' do
        expect(ProgramStream.inactive_enrollments(client)).to include(program_stream,  program_stream_inactive)
        expect(ProgramStream.inactive_enrollments(client)).not_to include(inactive_program)
      end

      it 'return records of entity enrollment' do
        expect(ProgramStream.inactive_enrollments(programmable, true)).to include(inactive_program)
        expect(ProgramStream.inactive_enrollments(programmable, true)).not_to include(program_stream,  program_stream_inactive)
      end
    end

    context 'without_status_by' do
      it 'return records of different client enrollment' do
        expect(ProgramStream.without_status_by(client).first).not_to eq program_stream
      end

      it 'return records of different entity enrollment' do
        expect(ProgramStream.without_status_by(programmable, true).first).not_to eq active_program
      end
    end

    context 'is_used?' do
      it 'return active client enrollment of the program' do
        expect(program_stream_active.is_used?).to be_truthy
      end
    end

    context 'modify field label from e-mail to email' do
      # client enrollment
      it 'auto update enrollment' do
        program_stream.update(enrollment: field)
        expect(client_enrollment.reload.properties).to eq({"email"=>"test@example.com", "age"=>"3", "description"=>"this is testing"})
      end

      # entity enrollment
      it 'auto update enrollment' do
        active_program.update(enrollment: field)
        expect(active_enrollment.reload.properties).to eq({"email"=>"test@example.com", "age"=>"3", "description"=>"this is testing"})
      end

      it 'auto update exit program' do
        program_stream.update(exit_program: field)
        expect(client_enrollment.leave_program.reload.properties).to eq({"email"=>"test@example.com", "age"=>"3", "description"=>"this is testing"})
      end

      it 'auto update trackings' do
        program_stream.trackings.first.update(fields: field)
        expect(client_enrollment.client_enrollment_trackings.reload.first.properties).to eq({"email"=>"test@example.com", "age"=>"3", "description"=>"this is testing"})
      end
    end
  end
end
