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

  def referred_from_hidden?
    'hidden' if params[:referral_type].presence == 'referred_to'
  end

  def referred_to_hidden?
    'hidden' if params[:referral_type].presence == 'referred_from'
  end

  def referred_from_ngo(referral)
    Organization.find_by(short_name: referral.referred_from).try(:full_name)
  end

  def referred_to_ngo(referral)
    referred_to = Organization.find_by(short_name: referral.referred_to).try(:full_name)
    referred_to.present? ? referred_to : referral.referred_to.titleize
  end

  def saved_referral(referral)
    return if referral.referred_to == 'external referral'
    Organization.switch_to referral.referred_to
    is_saved = Referral.find_by(slug: referral.slug).try(:saved)
    Organization.switch_to referral.referred_from.downcase
    is_saved
  end

end
