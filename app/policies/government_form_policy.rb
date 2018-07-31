class GovernmentFormPolicy < ApplicationPolicy
  def index?
    selected_country = Setting.first.try(:country_name) || params[:country].presence
    selected_country == 'cambodia'
  end

  def create?
    index? && ClientPolicy.new(user, record.client).create?
  end

  alias show? index?
  alias new? create?
  alias edit? create?
  alias update? create?
  alias destroy? create?
end
