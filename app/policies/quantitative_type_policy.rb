class QuantitativeTypePolicy < ApplicationPolicy
  def index?
    user.admin? || user.strategic_overviewer? || user.permission.specific_referral_data_readable
  end

  def create?
    user.admin? || user.permission.specific_referral_data_editable
  end

  alias update? create?
  alias destroy? create?
  alias version? index?
end
