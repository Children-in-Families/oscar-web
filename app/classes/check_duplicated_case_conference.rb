class CheckDuplicatedCaseConference
  attr_reader :case_conference, :case_conference_params
  def initialize(case_conference, case_conference_params)
    @case_conference = case_conference
    @case_conference_params = case_conference_params
  end

  def call
    return case_conference.save if !case_conference.persisted?
    case_conference_domains = case_conference.case_conference_domains
    case_conference_domains.each do |case_conference_domain|
      values = case_conference_params[:case_conference_domains_attributes].values.select{|values| values['domain_id'] == case_conference_domain.domain_id.to_s }
      presenting_problems = "#{case_conference_domain.presenting_problem} #{values[0]['presenting_problem']}"
      case_conference_domain.update_attributes({ domain_id: case_conference_domain.domain_id, presenting_problem: presenting_problems })
    end
    case_conference_attributes = case_conference.attributes.slice('client_strength', 'client_limitation', 'client_engagement', 'local_resource').map do |k,v|
      attr = case_conference_params[k]
      [k, "#{v} #{attr}"]
    end
    case_conference_attributes << [ 'user_ids', [*case_conference.user_ids, *case_conference_params['user_ids']].map(&:to_s).uniq ]
    case_conference.update_attributes(case_conference_attributes.to_h)
  end

end