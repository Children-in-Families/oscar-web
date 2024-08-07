FactoryGirl.define do
  factory :case_notes_custom_field_property, class: 'CaseNotes::CustomFieldProperty' do
    case_note nil
    properties ""
  end
end
