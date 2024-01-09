class SettingPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def research_module?
    current_org = Organization.current
    user.admin? && Setting.cache_first.country_name == 'cambodia' && !current_org.demo? && !current_org.cccu?
  end

  def custom_labels?
    user.admin?
  end

  def client_forms?
    user.admin?
  end

  def custom_form?
    user.admin?
  end

  alias care_plan? index?
  alias screening_forms? index?
  alias new? index?
  alias create? index?
  alias edit? index?
  alias update? index?
  alias default_columns? index?
  alias integration? index?
  alias header_count? index?
  alias family_case_management? client_forms?
  alias community? client_forms?
  alias test_client? client_forms?
  alias risk_assessment? create?
  alias customize_case_note? create?
  alias limit_tracking_form? create?
  alias finance_dashboard? create?
  alias internal_referral_module? create?
end
