class AssessmentPolicy < ApplicationPolicy
  def index?
    setting = Setting.first.try(:disable_assessment)
    setting.nil? ? true : !setting
  end

  def new?
    index? && (!record.client.uneligible_age? && !user.strategic_overviewer? || user.admin )
  end

  def edit?
    index? && (Date.current <= record.created_at + 6.days && !user.strategic_overviewer? || user.admin?)
  end

  alias create? new?
  alias show? index?
  alias update? edit?
end
