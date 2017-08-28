describe LeaveProgramHistory, 'class methods' do
  before do
    LeaveProgramHistory.destroy_all
  end

  context 'initial(leave_program)' do
    let!(:leave_program){ create(:leave_program) }
    it { expect(LeaveProgramHistory.count).to eq(1) }
    it { expect(LeaveProgramHistory.first.object['id']).to eq(leave_program.id) }
    it { expect(LeaveProgramHistory.first.object['properties']).to eq(leave_program.properties) }
  end
end
