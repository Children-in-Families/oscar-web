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
    ngos << ['MoSVY External System', 'MoSVY External System']
    ngos << ['external referral', "I don't see the NGO I'm looking for..."]
    ngos.to_h
  end

  def find_repeated_referred_client(referral)
    Client.find_by(global_id: referral.client_global_id)
  end

  def correct_referral_status(status)
    status == 'Exited' ? 'Rejected' : status
  end

  def find_new_and_existing_referrals(user)
    referrals = Referral.received.unsaved
    referrals = referrals.where('created_at > ?', user.activated_at) if user.deactivated_at?
    slugs = referrals.pluck(:slug).select(&:present?).uniq
    global_ids = referrals.pluck(:client_global_id).select(&:present?).uniq

    clients = Client.where('slug IN (:slugs) OR archived_slug IN (:slugs) OR global_id IN (:global_ids)', slugs: slugs, global_ids: global_ids)

    existinngs = []
    news = []

    referrals.each do |referral|
      client = clients.find { |c| c.slug == referral.slug || c.archived_slug == referral.slug || c.global_id == referral.client_global_id }
      if client.present?
        existinngs << referral
        referral.update_column(:client_id, client.id) unless referral.client_id
      else
        news << referral
      end
    end

    [existinngs, news]
  end
end
