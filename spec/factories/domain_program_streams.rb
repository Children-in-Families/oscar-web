FactoryBot.define do
  factory :domain_program_stream do
    association :domain, factory: :domain
    association :program_stream, factory: :program_stream
  end
end
