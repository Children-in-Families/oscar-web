namespace :ratanak_case_conference do
  desc "Migrate Case Conference Domain presenting problem"
  task migrate: :environment do
    Organization.switch_to 'ratanak'
    Assessment.all.each do |assessment|
      next if assessment.case_conference
      assessment_domains = assessment.assessment_domains.order(:domain_id)
      case_conference = CaseConference.new
      assessment_domains.each do |assessment_domain|
        case_conference.case_conference_domains.build(domain_id: assessment_domain.domain_id, presenting_problem: assessment_domain.reason)
      end
      case_conference.meeting_date = assessment.created_at
      case_conference.user_ids = whodunnit('Assessment', assessment.id)
      case_conference.client_id = assessment.client_id
      case_conference.save
      assessment.case_conference = case_conference
      assessment.save
      puts "Assessment ID #{assessment.id} CaseConference ID #{case_conference.id}"
    end
  end

  def whodunnit(type, id)
    user_id = PaperTrail::Version.find_by(event: 'create', item_type: type, item_id: id).try(:whodunnit)
    if user_id.blank? || (user_id.present? && user_id.include?('@rotati'))
      object = type.constantize.find(id)
      user_id = object.has_attribute?(:user_id) ? object&.user_id : object.try(:parent)&.user_id
      if user_id.nil?
        return user_ids = object.try(:parent)&.users&.ids || []
      end
    end

    [User.find_by(id: user_id).id]
  end

end
