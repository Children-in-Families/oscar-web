FactoryGirl.define do
  factory :program_stream_permission do
    association :program_stream, factory: :program_stream
    association :user, factory: :user
  end
end
