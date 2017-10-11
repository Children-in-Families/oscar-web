FactoryGirl.define do
  factory :program_stream_permission do
    user nil
    program_stream nil
    readable false
    editable false
  end
end
