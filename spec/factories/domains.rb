FactoryBot.define do
  factory :domain do
    sequence(:name)  { |n| "#{FFaker::Name.name}#{n}" }
    sequence(:identity)  { |n| "AB-#{n}" }
    domain_type { 'client' }
    description { FFaker::Lorem.paragraph }
    association :domain_group, factory: :domain_group
    custom_domain { false }

    to_create do |instance|
      instance.id = Domain.create_with(name: instance.name, identity: instance.identity, domain_group: instance.domain_group, domain_type: instance.domain_type, **instance.attributes)
                          .find_or_create_by!(name: instance.name).id

      instance.reload
    end

    trait :custom do
      custom_domain { true }
      association :custom_assessment_setting, factory: :custom_assessment_setting
    end
  end
end
