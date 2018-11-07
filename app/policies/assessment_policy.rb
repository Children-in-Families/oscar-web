class AssessmentPolicy < ApplicationPolicy
  def index?
    setting = Setting.first.try(:disable_assessment)
    setting.nil? ? true : !setting
  end

  def new?
    index? && !record.client.uneligible_age?
  end

  def edit?
    index? && Date.current <= record.created_at + 1.week && !user.strategic_overviewer?
  end

  alias create? new?
  alias show? index?
  alias update? edit?
end
