class RejectReferralFamilyWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(staff_member, referred_to, referral_id)
    referral = FamilyReferral.find referral_id
    Organization.switch_to referral.referred_from

    user = User.notify_email.find referral.referee_id
    RejectReferralFamilyMailer.family_rejection_email(staff_member, referred_to, referral).deliver_now if user.present? && !user.disable?
  end
end
