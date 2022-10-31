FactoryBot.define do
  factory :referral_source do
    name { FFaker::Name.name }
    description { FFaker::Lorem.paragraph }  
  end
end
