module InternalReferralHelper
  def internal_referral_start_date(entity)
    accepted_date = entity.enter_ngos.first&.accepted_date
    ((accepted_date || entity.initial_referral_date)).strftime("%Y-%m-%d")
  end

end
