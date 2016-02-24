FactoryGirl.define do
  factory :task do
    name 'MyString'
    domain 'MyString'
    created_date '2015-11-30'
    finished_date '2015-11-30'
    order 1
    kinship_or_foster_care_case nil
  end
end
