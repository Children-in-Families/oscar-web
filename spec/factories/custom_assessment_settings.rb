FactoryBot.define do
  factory :custom_assessment_setting do
    custom_assessment_name { "MyString" }
    max_custom_assessment { 4 }
    custom_assessment_frequency { "MyString" }
    custom_age { 1 }
    setting_id { 1 }
  end
end
