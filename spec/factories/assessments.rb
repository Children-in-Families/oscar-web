FactoryGirl.define do
  factory :assessment do
    date { Faker::Date.between(8.months.ago, 4.months.ago) }
    present { Faker::Name.name }
    domain_1a_score { (1..4).to_a.sample }
    domain_1b_score { (1..4).to_a.sample }
    domain_2a_score { (1..4).to_a.sample }
    domain_2b_score { (1..4).to_a.sample }
    domain_3a_score { (1..4).to_a.sample }
    domain_3b_score { (1..4).to_a.sample }
    domain_4a_score { (1..4).to_a.sample }
    domain_4b_score { (1..4).to_a.sample }
    domain_5a_score { (1..4).to_a.sample }
    domain_5b_score { (1..4).to_a.sample }
    domain_6a_score { (1..4).to_a.sample }
    domain_6b_score { (1..4).to_a.sample }
    domain_1a_notes { Faker::Hipster.paragraph }
    domain_1b_notes { Faker::Hipster.paragraph }
    domain_2a_notes { Faker::Hipster.paragraph }
    domain_2b_notes { Faker::Hipster.paragraph }
    domain_3a_notes { Faker::Hipster.paragraph }
    domain_3b_notes { Faker::Hipster.paragraph }
    domain_4a_notes { Faker::Hipster.paragraph }
    domain_4b_notes { Faker::Hipster.paragraph }
    domain_5a_notes { Faker::Hipster.paragraph }
    domain_5b_notes { Faker::Hipster.paragraph }
    domain_6a_notes { Faker::Hipster.paragraph }
    domain_6b_notes { Faker::Hipster.paragraph }
    reason { Faker::Hipster.paragraph }
  end
end
