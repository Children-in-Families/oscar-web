class InternalReferralPolicy < ApplicationPolicy
  def edit?
    return true if user.admin?
    record.is_editable?
  end

end
