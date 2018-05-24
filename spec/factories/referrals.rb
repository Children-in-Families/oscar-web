FactoryGirl.define do
  factory :referral do
    slug "MyString"
    date_of_referral "2018-05-24"
    referred_to "MyString"
    referred_from "MyString"
    referral_reason "MyText"
    name_of_referee "MyString"
    referral_phone "MyString"
    saved false
    client nil
  end
end
