FactoryGirl.define do
  factory :domain_group do
    sequence(:name)  { |n| "#{n}-#{FFaker::Name.name}" }

    after(:build) do |dg|
      dg.case_note_domain_groups << FactoryGirl.create(:case_note_domain_group)
    end
  end
end
