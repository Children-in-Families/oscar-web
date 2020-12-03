FactoryGirl.define do
  factory :global_identity do
    ulid { ULID.generate }
  end
end
