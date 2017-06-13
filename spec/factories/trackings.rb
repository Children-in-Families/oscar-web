FactoryGirl.define do
  # factory :tracking do
  #   properties { {"e-mail"=>"cif@cambodianfamily.com", "age"=>"3", "description"=>"this is testing"}.to_json }
  #   association :client_enrollment
  #   association :program_stream
  # end
  factory :tracking do
    name FFaker::Name.name
    fields [{"name"=>"email", "type"=>"text", "label"=>"e-mail", "subtype"=>"email", "required"=>true, "className"=>"form-control"}, {"max"=>"5", "min"=>"1", "name"=>"age", "type"=>"number", "label"=>"age", "required"=>true, "className"=>"form-control"}, {"name"=>"description", "type"=>"text", "label"=>"description", "subtype"=>"text", "required"=>true, "className"=>"form-control"}]
    association :program_stream
  end
end
