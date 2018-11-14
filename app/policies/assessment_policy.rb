class AssessmentPolicy < ApplicationPolicy
  def index?
    Setting.first.try(:enable_default_assessment) || Setting.first.try(:enable_customized_assessment)
  end

  def new?
    index? && !record.client.uneligible_age?
  end

  alias create? new?
  alias show? index?
  alias edit? index?
  alias update? index?
end
