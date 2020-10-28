FactoryGirl.define do
  factory :case_note do
    meeting_date { FFaker::Time.date }
    attendee { FFaker::Name.name }
    association :client, factory: :client
    association :assessment, factory: :assessment
    interaction_type 'Visit'

    transient do
      single_domain_group { false }
    end

    after(:build) do |case_note, options|
      if options.single_domain_group
        case_note.selected_domain_group_ids = Domain.csi_domains.pluck(:domain_group_id)
      else
        domains = Domain.csi_domains.count < 12 ? create_list(:domain, (12 - Domain.csi_domains.count)) : Domain.csi_domains
        case_note.domain_groups << DomainGroup.where(id: domains.map(&:domain_group_id))
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
