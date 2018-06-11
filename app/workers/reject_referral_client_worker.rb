class RejectReferralClientWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(staff_member, referred_to, referral_id)
    referral = Referral.find referral_id
    Organization.switch_to referral.referred_from

    user = User.find referral.referee_id
    RejectReferralClientMailer.client_rejection_email(staff_member, referred_to, referral).deliver_now if user.present? && !user.disable?
  end
end
