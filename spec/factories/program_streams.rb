FactoryGirl.define do
  factory :program_stream do
    name FFaker::Name.name
    enrollment [{'label'=>'hello','type'=>'text'}]
    tracking [{'label'=>'world','type'=>'text'}]
    exit_program [{'label'=>'Mr.ABC','type'=>'text'}]
    rules { {'rules'=>[{'id'=>'age', 'type'=>'integer', 'field'=>'age', 'input'=>'text', 'value'=>'2', 'operator'=>'equal'}], 'condition'=>'AND'}.to_json}
  end
end
