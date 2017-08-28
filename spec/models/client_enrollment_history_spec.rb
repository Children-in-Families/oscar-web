describe ClientEnrollmentHistory, 'class method' do
  before do
    ClientEnrollmentHistory.destroy_all
  end

  context 'initial(client_enrollment)' do
    let!(:client_enrollment_1){ create(:client_enrollment) }
    it { expect(ClientEnrollmentHistory.count).to eq(1) }
    it { expect(ClientEnrollmentHistory.first.object['id']).to eq(client_enrollment_1.id) }
    it { expect(ClientEnrollmentHistory.first.object['properties']).to eq(client_enrollment_1.properties) }
  end

  context 'format_property(attributes)' do
    enrollment = [{"name"=>"1502695799170", "type"=>"checkbox-group", "label"=>"Checkbox Group", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "className"=>"checkbox-group"}, {"name"=>"1502695814937", "type"=>"radio-group", "label"=>"Radio.Group", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "className"=>"radio-group"}, {"name"=>"1502695818113", "type"=>"select", "label"=>"Select", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "multiple"=>true, "className"=>"form-control"}]
    let!(:program_stream) { FactoryGirl.create(:program_stream, enrollment: enrollment.to_json) }
    let!(:client_enrollment_2){ FactoryGirl.create(:client_enrollment, program_stream: program_stream, properties: {"Checkbox Group"=>["Option 1"], "Radio.Group"=>"Option 1", "Select"=>["Option 1"]}.to_json) }
    it 'join string and dot with underscore and as lowercase' do
      expect(ClientEnrollmentHistory.where({'object.id' => client_enrollment_2.id}).first.object['properties']).to eq({"checkbox_group"=>["Option 1"], "radio_group"=>"Option 1", "select"=>["Option 1"]})
    end
  end
end
