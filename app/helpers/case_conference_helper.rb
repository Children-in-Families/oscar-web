module CaseConferenceHelper
  def case_conference_readable?
    return true if current_user.admin? || current_user.strategic_overviewer? || current_user.hotline_officer?
  end
end
