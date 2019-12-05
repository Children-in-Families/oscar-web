FactoryGirl.define do
  factory :call do
    receiving_staff_id 1
    start_datetime DateTime.now
    end_datetime DateTime.now
    association :caller, factory: :caller
  end
end
