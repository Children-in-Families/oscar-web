FactoryGirl.define do
  factory :donor do
    name { FFaker::Name.name }
    description FFaker::Lorem.sentence
  end
end
