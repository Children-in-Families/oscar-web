FactoryGirl.define do
  factory :marketing do
    date '2015-11-30'
    channel 'MyString'
    idea 'MyString'
    keywords 'MyText'
    notes 'MyText'
    status 'MyString'
    case_worker nil
  end
end
