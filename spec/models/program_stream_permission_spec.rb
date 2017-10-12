describe ProgramStreamPermission, 'associations' do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:program_stream) }
end

describe ProgramStreamPermission, 'scopes' do
  let!(:user) { create(:user, :admin) }
  let!(:first_program) { create(:program_stream, name: 'DEF') }
  let!(:first_program_permission) { create(:program_stream_permission, user: user, program_stream: first_program) }

  let!(:second_program) { create(:program_stream, name: 'ABC') }
  let!(:second_program_permission) { create(:program_stream_permission, user: user, program_stream: second_program) }

  context 'order by program name' do
    it 'should return second program first' do
      expect(ProgramStreamPermission.order_by_program_name.first.program_stream_id).to eq(second_program.id) 
    end
  end
end 