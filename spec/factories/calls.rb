FactoryBot.define do
  factory :call do
    answered_call { false }
    called_before { false }
    receiving_staff_id { 1 }
    date_of_call { Date.today }
    start_datetime { DateTime.now }
    association :referee, factory: :referee
    call_type { "Wrong Number" }
    childsafe_agent { true }
  end
end
