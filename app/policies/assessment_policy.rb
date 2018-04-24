class AssessmentPolicy < ApplicationPolicy
  def index?
    setting = Setting.first.try(:disable_assessment)
    setting.nil? ? true : !setting
  end

  alias show? index?
  alias new? index?
  alias create? index?
  alias edit? index?
  alias update? index?
end
