FactoryGirl.define do
  factory :case_note do
    meeting_date { FFaker::Time.date }
    attendee { FFaker::Name.name }
    association :client, factory: :client
    association :assessment, factory: :assessment
    interaction_type 'Visit'

    transient do
      single_domain_group { true }
    end

    after(:build) do |case_note|
      if single_domain_group
        domains = Domain.csi_domains.count < 12 ? create_list(:domain, (12 - Domain.csi_domains.count)) : Domain.csi_domains
        case_note.domain_groups << DomainGroup.where(id: domains.map(&:domain_group_id))
        case_note.selected_domain_group_ids = domains.map(&:domain_group_id)
      else
        binding.pry
        case_note.selected_domain_group_ids = domains.map(&:domain_group_id)
      end
    end

    trait :custom do
      custom true
      after(:build) do |case_note|
        case_note.custom_assessment_setting = create(:custom_assessment_setting)
      end
    end
  end
end
