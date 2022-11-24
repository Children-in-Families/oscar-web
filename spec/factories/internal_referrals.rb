FactoryBot.define do
  factory :internal_referral do
    referral_date { "2021-06-06 14:46:39" }
    client_id { 1 }
    user_id { 1 }
    client_representing_problem { "MyText" }
    emergency_note { "MyText" }
    referral_reason { "MyText" }
    crisis_management { "MyText" }
    attachments { "MyString" }
  end
end
