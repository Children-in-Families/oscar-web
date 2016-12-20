FactoryGirl.define do
  factory :user do
    sequence(:email)  { |n| "#{n}#{FFaker::Internet.email}" }
    first_name FFaker::Name.first_name
    last_name FFaker::Name.last_name
    password '12345678'
    password_confirmation '12345678'
    roles 'case worker'

    # association :organization, factory: :organization
  end
end
