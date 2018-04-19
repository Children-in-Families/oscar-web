class SettingPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def country?
    true
  end

  def default_columns?
    user.admin?
  end
end
