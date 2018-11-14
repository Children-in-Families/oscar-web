FactoryGirl.define do
  factory :assessment do
    customized false
    association :client, factory: :client
  end
end
