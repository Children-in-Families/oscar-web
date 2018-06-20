module ReferralsHelper
  def referral_date(referral)
    referral.persisted? ? referral.date_of_referral : Date.today
  end

  def referee_name(referral)
    referral.persisted? ? referral.name_of_referee : current_user.name
  end

  def referee_phone(referral)
    referral.persisted? ? referral.referral_phone : current_user.mobile
  end

  def referee_id(referral)
    referral.persisted? ? referral.referee_id : current_user.id
  end

  def referred_from_hidden?(referral)
    'hidden' if referral_type(referral) == 'referred_to'
  end

  def referred_to_hidden?(referral)
    'hidden' if referral_type(referral) == 'referred_from'
  end

  def referral_type(referral)
    current_organization.short_name == referral.try(:referred_to) ? 'referred_from' : 'referred_to'
  end
end
