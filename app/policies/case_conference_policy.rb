class CaseConferencePolicy < ApplicationPolicy
  include CaseConferenceHelper

  def index?
    Setting.first.enable_default_assessment || Setting.first.enable_custom_assessment
  end

  def show?
    enable_assessment = record.default? ? Setting.first.enable_default_assessment : Setting.first.enable_custom_assessment
    readable_user     = user.admin? || user.strategic_overviewer? ? true : user.permission&.assessments_readable
    enable_assessment && readable_user
  end

  def new?(value = '', custom_assessment = nil)
    return false if user.strategic_overviewer?

    setting = Setting.first
    enable_assessment = record.default? ? setting.enable_default_assessment? : setting.enable_custom_assessment?
    editable_user = user.admin? ? true : user.permission&.assessments_editable
    enable_assessment && editable_user
  end

  def edit?
    setting = Setting.first
    enable_assessment = setting.enable_default_assessment?
    return true if setting.enable_default_assessment? && user.admin?

    return false if can_edit?(user, record) || case_conference_editable?(record.meeting_date)
    editable_user = user.admin? ? true : user.permission&.assessments_editable
    enable_assessment && (editable_user && !record.client&.exit_ngo? || user.admin?)
  end

  def can_edit?(user, case_conference)
    return case_conference.created_at < 7.days.ago unless user.strategic_overviewer?
  end

  alias create? new?
  alias update? edit?
end
