FactoryGirl.define do
  factory :family_member do
    adult_name { FFaker::Name.name }
    date_of_birth "2018-07-09"
    occupation { FFaker::Job.title }
    relation { FFaker::Name.name }
    association :family
  end
end
