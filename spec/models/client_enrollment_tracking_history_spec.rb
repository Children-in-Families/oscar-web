describe ClientEnrollmentTrackingHistory, 'class methods' do
  before do
    ClientEnrollmentTrackingHistory.destroy_all
  end

  context 'initial(client_enrollment_tracking)' do
    let!(:client_enrollment_tracking){ create(:client_enrollment_tracking) }
    it { expect(ClientEnrollmentTrackingHistory.count).to eq(1) }
    it { expect(ClientEnrollmentTrackingHistory.first.object['id']).to eq(client_enrollment_tracking.id) }
    it { expect(ClientEnrollmentTrackingHistory.first.object['properties']).to eq(client_enrollment_tracking.properties) }
  end

  context 'format_property(attributes)' do
    fields = [{"name"=>"1502695799170", "type"=>"checkbox-group", "label"=>"Checkbox Group", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "className"=>"checkbox-group"}, {"name"=>"1502695814937", "type"=>"radio-group", "label"=>"Radio.Group", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "className"=>"radio-group"}, {"name"=>"1502695818113", "type"=>"select", "label"=>"Select", "values"=>[{"label"=>"Option 1", "value"=>"option-1", "selected"=>true}], "multiple"=>true, "className"=>"form-control"}]
    let!(:tracking) { create(:tracking, fields: fields.to_json) }
    let!(:client_enrollment_tracking){ create(:client_enrollment_tracking, tracking: tracking, properties: {"Checkbox Group"=>["Option 1"], "Radio.Group"=>"Option 1", "Select"=>["Option 1"]}.to_json) }
    it 'join string and dot with underscore and as lowercase' do
      expect(ClientEnrollmentTrackingHistory.where({'object.id' => client_enrollment_tracking.id}).first.object['properties']).to eq({"checkbox_group"=>["Option 1"], "radio_group"=>"Option 1", "select"=>["Option 1"]})
    end
  end
end
