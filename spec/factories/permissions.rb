FactoryGirl.define do
  factory :permission do
    name "MyString"
    user nil
    readable false
    editable false
  end
end
