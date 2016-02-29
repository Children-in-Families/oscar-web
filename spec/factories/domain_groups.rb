FactoryGirl.define do
  factory :domain_group do
    sequence(:name)  { |n| n }
  end
end
