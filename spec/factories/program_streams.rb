FactoryGirl.define do
  default_field = [{"name"=>"email", "type"=>"text", "label"=>"e-mail", "subtype"=>"email", "required"=>true, "className"=>"form-control"}, {"max"=>"5", "min"=>"1", "name"=>"age", "type"=>"number", "label"=>"age", "required"=>true, "className"=>"form-control"}, {"name"=>"description", "type"=>"text", "label"=>"description", "subtype"=>"text", "required"=>true, "className"=>"form-control"}]

  rule_condition = {'rules'=>[{'id'=>'age', 'type'=>'integer', 'field'=>'age', 'input'=>'text', 'value'=>'2', 'operator'=>'greater'}], 'condition'=>'AND'}.to_json

  factory :program_stream do
    entity_type 'Client'
    sequence(:name)  { |n| "#{FFaker::Name.name}-#{n}" }
    rules { rule_condition }
    enrollment default_field
    exit_program default_field
    quantity 10
    after(:build) do |ps|
      ps.services << create(:service)
    end

    trait :attached_with_family do
      entity_type 'Family'
    end

    trait :attached_with_community do
      entity_type 'Community'
    end
  end
end
