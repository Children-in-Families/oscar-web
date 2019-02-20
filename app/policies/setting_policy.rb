class SettingPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def research_module?
    current_org = Organization.current
    user.admin? && Setting.first.country_name == 'cambodia' && !current_org.demo? && !current_org.cccu?
  end

  alias new? index?
  alias create? index?
  alias edit? index?
  alias update? index?
  alias default_columns? index?
end
