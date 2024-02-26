module CaseConferenceHelper
  def case_conference_readable?
    return true unless current_user.strategic_overviewer? || current_user.hotline_officer?
  end

  def case_conference_editable?(meeting_date)
    setting = Setting.first
    max_case_case = setting.try(:case_conference_limit).zero? ? 2 : setting.try(:case_conference_limit)
    case_note_frequency = setting.try(:case_conference_frequency)
    meeting_date <= max_case_case.send(case_note_frequency).ago
  end

  def case_conference_domain_ordered_by_name(case_conference)
    if case_conference.persisted?
      case_conference.case_conference_order_by_domain_name.includes(:domain, :case_conference_addressed_issues)
    else
      case_conference.case_conference_order_by_domain_name
    end
  end
end
