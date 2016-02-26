FactoryGirl.define do
  factory :domain do
    name FFaker::Name.name
    identity FFaker::Name.name
    description FFaker::Lorem.paragraph
    association :domain_group, factory: :domain_group
  end
end
