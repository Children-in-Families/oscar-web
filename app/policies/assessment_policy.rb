class AssessmentPolicy < ApplicationPolicy
  def index?
    Setting.first.enable_default_assessment || Setting.first.enable_custom_assessment
  end

  def show?
    enable_assessment = record.default? ? Setting.first.enable_default_assessment : Setting.first.enable_custom_assessment
    readable_user     = user.admin? || user.strategic_overviewer? ? true : user.permission.assessments_readable
    enable_assessment && readable_user
  end

  def new?
    return false if user.strategic_overviewer?
    setting = Setting.first
    enable_assessment = record.default? ? setting.enable_default_assessment? && record.client.eligible_default_csi? : setting.enable_custom_assessment? && record.client.eligible_custom_csi?
    editable_user     = user.admin? ? true : user.permission.assessments_editable
    enable_assessment && editable_user && !record.client.exit_ngo? && record.client.can_create_assessment?(record.default)
  end

  def edit?
    return false if user.strategic_overviewer?
    setting = Setting.first
    enable_assessment = record.default? ? setting.enable_default_assessment? : setting.enable_custom_assessment?
    return true if enable_assessment && user.admin?
    editable_user     = user.admin? ? true : user.permission.assessments_editable
    enable_assessment && (editable_user && !record.client.exit_ngo? && Date.current <= record.created_at + 6.days || user.admin?)
  end

  alias create? new?
  alias update? edit?
end
