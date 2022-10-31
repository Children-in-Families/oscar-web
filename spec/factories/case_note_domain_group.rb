FactoryBot.define do
  factory :case_note_domain_group do
    note { FFaker::Lorem.paragraph }
    case_note
    domain_group
    after :build do |cndg|
      cndg.case_note_id = cndg.case_note.id
      cndg.save
    end
  end
end
