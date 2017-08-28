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

  context 'format_property(attributes)' do
    exit_program = [{"name"=>"1502695799170", "type"=>"checkbox-group", "label"=>"Checkbox Group", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "className"=>"checkbox-group"}, {"name"=>"1502695814937", "type"=>"radio-group", "label"=>"Radio.Group", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "className"=>"radio-group"}, {"name"=>"1502695818113", "type"=>"select", "label"=>"Select", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "multiple"=>true, "className"=>"form-control"}]
    let!(:program_stream) { create(:program_stream, exit_program: exit_program.to_json) }
    let!(:leave_program){ create(:leave_program, program_stream: program_stream, properties: {"Checkbox Group"=>["Option 1"], "Radio.Group"=>"Option 1", "Select"=>["Option 1"]}.to_json) }
    it 'join string and dot with underscore and as lowercase' do
      expect(LeaveProgramHistory.where({'object.id' => leave_program.id}).first.object['properties']).to eq({"checkbox_group"=>["Option 1"], "radio_group"=>"Option 1", "select"=>["Option 1"]})
    end
  end
end
