describe ProgramStream, 'associations' do
  it { is_expected.to have_many(:domain_program_streams) }
  it { is_expected.to have_many(:domains).through(:domain_program_streams) }
  it { is_expected.to have_many(:client_enrollments) }
  it { is_expected.to have_many(:clients).through(:client_enrollments) }
  it { is_expected.to have_many(:trackings) }
  it { is_expected.to have_many(:leave_programs) }
end

describe ProgramStream, 'validations' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:rules) }
  it { is_expected.to validate_presence_of(:enrollment) }
  it { is_expected.to validate_presence_of(:tracking) }
  it { is_expected.to validate_presence_of(:exit_program) }
end

describe ProgramStream, 'uniqueness enrollment tracking and exit_program' do
  rules         = {'rules'=>[{'id'=>'age', 'type'=>'integer', 'field'=>'age', 'input'=>'text', 'value'=>'2', 'operator'=>'equal'}], 'condition'=>'AND'}.to_json
  enrollment    = [{'label'=>'hello','type'=>'text'}, {'label'=>'hello','type'=>'text'}]
  tracking      = [{'label'=>'world','type'=>'text'}, {'label'=>'world','type'=>'text'}]
  exit_program  = [{'label'=>'Mr.ABC','type'=>'text'}, {'label'=>'Mr.ABC','type'=>'text'}]
  program_stream_duplicate = ProgramStream.new(name: 'Test', rules: rules, enrollment: enrollment, tracking: tracking, exit_program: exit_program)

  it 'return errors fields duplicate' do
    program_stream_duplicate.save
    expect(program_stream_duplicate.errors.full_messages).to include("Enrollment Fields duplicated!", "Tracking Fields duplicated!", "Exit program Fields duplicated!")
  end
end

describe ProgramStream, 'methods' do
  let!(:client) { create(:client) }
  let!(:second_client) { create(:client) }
  let!(:program_stream) { create(:program_stream) }
  let!(:client_enrollment) { create(:client_enrollment, client: client, program_stream: program_stream)}
  let!(:second_client_enrollment) { create(:client_enrollment, client: second_client, program_stream: program_stream)}

  it 'return last record of program stream' do
    expect(program_stream.last_enrollment).to eq second_client_enrollment
  end
end
