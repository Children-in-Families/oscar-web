FactoryBot.define do
  factory :changelog_type do
    change_type { 'added' }
    description { 'Add changelog feature' }
    association :changelog, factory: :changelog
  end
end
