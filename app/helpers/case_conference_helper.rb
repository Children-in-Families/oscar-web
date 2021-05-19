module CaseConferenceHelper
  def case_conference_readable?
    return true unless current_user.strategic_overviewer? || current_user.hotline_officer?
  end

  def case_conference_editable?(meeting_date)
    setting = Setting.first
    max_case_case = setting.try(:case_conference_limit).zero? ? 2 : setting.try(:case_conference_limit).zero?
    case_note_frequency = setting.try(:case_conference_frequency)
    meeting_date <= max_case_case.send(case_note_frequency).ago
  end
end
