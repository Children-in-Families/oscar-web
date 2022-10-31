FactoryBot.define do
  factory :risk_assessment do
    assessment_date "2022-08-17 08:19:40"
    protection_concern "MyString"
    other_protection_concern_specification "MyString"
    client_perspective "MyText"
    has_known_chronic_disease false
    has_disability false
    has_hiv_or_aid false
    known_chronic_disease_specification "MyString"
    disability_specification "MyString"
    hiv_or_aid_specification "MyString"
    relevant_referral_information "MyText"
    vulnerability_ids 1
  end
end
