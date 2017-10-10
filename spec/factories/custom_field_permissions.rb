FactoryGirl.define do
  factory :custom_field_permission do
    user nil
    custom_field nil
    readable false
    editable false
  end
end
