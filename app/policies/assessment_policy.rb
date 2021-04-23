class AssessmentPolicy < ApplicationPolicy
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

    association = record.family_id ? 'family' : 'client'
    setting = Setting.first
    if custom_assessment
      enable_assessment = record.default? ? setting.enable_default_assessment? && record.public_send(association).eligible_default_csi? : setting.enable_custom_assessment? && record.public_send(association).eligible_custom_csi?(custom_assessment)
    else
      enable_assessment = record.default? ? setting.enable_default_assessment? && record.public_send(association).eligible_default_csi? : setting.enable_custom_assessment?
    end
    editable_user = user.admin? ? true : user.permission&.assessments_editable
    enable_assessment && editable_user && !record.public_send(association).exit_ngo? && record.public_send(association).can_create_assessment?(record.default, value)
  end

  def edit?
    return false unless user.admin?

    setting = Setting.first
    enable_assessment = record.default? ? setting.enable_default_assessment? : setting.enable_custom_assessment?
    return true if enable_assessment && user.admin?

    editable_user = user.admin? ? true : user.permission&.assessments_editable
    enable_assessment && (editable_user && !record.client&.exit_ngo? || user.admin?)
  end

  alias create? new?
  alias update? edit?
end
