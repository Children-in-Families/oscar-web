FactoryGirl.define do
  factory :case_note_domain_group do
    note { FFaker::Lorem.paragraph}
    association :case_note, factory: :case_note
    association :domain_group, factory: :domain_group
  end
end
