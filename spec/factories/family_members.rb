FactoryGirl.define do
  factory :family_member do
    name_of_adult_member "MyString"
    date_of_birth "2018-07-09"
    occupation "MyString"
    relationship_with_children "MyString"
    family nil
  end
end
