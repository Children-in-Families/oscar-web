class CommunityPolicy < ApplicationPolicy
  def show?
    !current_setting.hide_community?
  end

  alias index? show?
  alias show? show?
  alias edit? show?
  alias update? show?
  alias create? show?
  alias edit? show?
  alias destroy? show?

  def current_setting
    @current_setting ||= Setting.first
  end
end
