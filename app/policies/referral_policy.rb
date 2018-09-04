class ReferralPolicy < ApplicationPolicy
  def edit?
    org = Organization.current
    return false if org.short_name == record.referred_to
    return true if record.non_oscar_ngo?
    Organization.switch_to record.referred_to
    is_saved = Referral.find_by(slug: record.slug, date_of_referral: record.date_of_referral).try(:saved)
    Organization.switch_to org.short_name
    !is_saved
  end

  alias update? edit?
end
