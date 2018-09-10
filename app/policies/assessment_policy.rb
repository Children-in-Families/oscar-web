class AssessmentPolicy < ApplicationPolicy
  def index?
    setting = Setting.first.try(:disable_assessment)
    setting.nil? ? true : !setting
  end

  def new?
    index? && !record.client.uneligible_age?
  end

  alias create? new?
  alias show? index?
  alias edit? index?
  alias update? index?
end
