FactoryGirl.define do
  factory :government_form do
    name { FFaker::Name.name }
    association :client, factory: :client
    association :province, factory: :province
    association :district, factory: :district
    association :commune, factory: :commune
    association :village, factory: :village
    interview_province_id nil
    assessment_province_id nil
    primary_carer_province_id nil
  end
end
