class AssessmentPolicy < ApplicationPolicy
  def index?
    setting = Setting.first.try(:disable_assessment)
    setting.nil? ? true : !setting
  end

  def create?
    index? && client_under_18_years?
  end

  alias new? create?
  alias show? index?
  alias edit? index?
  alias update? index?

  private

    def client_under_18_years?
      return true unless record.client.date_of_birth.present?
      client_age = record.client.age_as_years
      client_age < 18 ? true : false
    end
end
