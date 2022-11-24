FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "#{FFaker::Name.name}-#{n}" }
     description { FFaker::Lorem.sentence }

    trait :able do
      name { 'ABLE' }
    end

    trait :emergency_care do
      name { 'Emergency Care' }
    end

    trait :kinship_care do
      name { 'Kinship Care' }
    end

    trait :foster_care do
      name { 'Foster Care' }
    end
  end
end
