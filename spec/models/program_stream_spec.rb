describe ProgramStream, 'associations' do
  it { is_expected.to have_many(:domain_program_streams).dependent(:destroy) }
  it { is_expected.to have_many(:domains).through(:domain_program_streams) }
  it { is_expected.to have_many(:client_enrollments).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:clients).through(:client_enrollments) }
  it { is_expected.to have_many(:trackings).dependent(:restrict_with_error) }
  it { is_expected.to have_many(:leave_programs) }
end

describe ProgramStream, 'scope' do
  let!(:first_program_stream) { create(:program_stream, name: 'def') }
  let!(:second_program_stream) { create(:program_stream, name: 'abc') }

  context 'ordered' do
    it 'return the second record first' do
      expect(ProgramStream.ordered.first).to eq second_program_stream
    end

    it 'return the first record second' do
      expect(ProgramStream.ordered.last).to eq first_program_stream
    end
  end
end

describe ProgramStream, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:rules) }
  it { is_expected.to validate_presence_of(:enrollment) }
  it { is_expected.to validate_presence_of(:exit_program) }
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

describe ProgramStream, 'validate remove fields' do
  let!(:client) { create(:client) }
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream) }

  default_fields = [{"max"=>"5", "min"=>"1", "name"=>"age", "type"=>"number", "label"=>"age", "required"=>true, "className"=>"form-control"}, {"name"=>"description", "type"=>"text", "label"=>"description", "subtype"=>"text", "required"=>true, "className"=>"form-control"}]
  
  it 'return Enrollment cannot remove field since it already in use' do
    program_stream.update_attributes(enrollment: default_fields)
    expect(program_stream.errors.full_messages).to include("Enrollment e-mail cannot be removed/updated since it is already in use.")
  end

end

describe ProgramStream, 'methods' do
  let!(:client) { create(:client) }
  let!(:second_client) { create(:client) }
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream)}
  let!(:second_client_enrollment) { create(:client_enrollment, client: second_client, program_stream: program_stream)}
  
  context 'last_enrollment' do
    it 'should return last record of program stream' do
      expect(program_stream.last_enrollment).to eq second_client_enrollment
    end
    it 'should not return record that not last' do
      expect(program_stream.last_enrollment).not_to eq client_enrollment
    end
  end
end
