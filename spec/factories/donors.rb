FactoryBot.define do
  factory :donor do
    name { FFaker::Name.name }
    description FFaker::Lorem.sentence
    code { rand(1000..9999)}
  end
end
