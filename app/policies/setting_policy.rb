class SettingPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  alias new? index?
  alias create? index?
  alias edit? index?
  alias update? index?
  alias default_columns? index?
end
