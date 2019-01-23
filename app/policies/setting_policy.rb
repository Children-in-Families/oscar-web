class SettingPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def research_module?
    user.admin? && Setting.first.country_name == 'cambodia'
  end

  alias new? index?
  alias create? index?
  alias edit? index?
  alias update? index?
  alias default_columns? index?
end
