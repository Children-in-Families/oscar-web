FactoryGirl.define do
  factory :case_note do
    date { Faker::Date.between(3.months.ago, 1.month.ago) }
    present { Faker::Name.name }
    domain_1_notes { Faker::Hipster.paragraph }
    domain_2_notes { Faker::Hipster.paragraph }
    domain_3_notes { Faker::Hipster.paragraph }
    domain_4_notes { Faker::Hipster.paragraph }
    domain_5_notes { Faker::Hipster.paragraph }
    domain_6_notes { Faker::Hipster.paragraph }
  end
end
