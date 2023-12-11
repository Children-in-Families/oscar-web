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

  def referral_email(referral)
    referral.persisted? ? referral.referee_email : current_user.email
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

  def ngo_hash_mapping
    ngos = Organization.pluck(:short_name, :full_name)
    ngos << ["MoSVY External System", "MoSVY External System"]
    ngos << ["external referral", "I don't see the NGO I'm looking for..."]
    ngos.to_h
  end

  def find_repeated_referred_client(referral)
    Client.find_by(global_id: referral.client_global_id)
  end
end
