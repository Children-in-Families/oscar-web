class SettingPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def country?
    true
  end

  alias new? index?
  alias create? index?
  alias edit? index?
  alias update? index?
  alias default_columns? index?
end
