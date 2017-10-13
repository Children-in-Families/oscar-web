FactoryGirl.define do
  factory :permission do
    association :user, factory: :user
    case_notes_readable false
    case_notes_editable false
    assessments_readable false
    assessments_editable false
  end
end
