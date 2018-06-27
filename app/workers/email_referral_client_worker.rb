class EmailReferralClientWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(referral_from, referral_to, slug)
    Organization.switch_to referral_to
    existed = Client.exists?(slug: slug)
    admins = User.admins.non_locked.referral_notification_email
    managers = User.managers.non_locked.referral_notification_email
    ReferralClientMailer.send_to(admins, referral_from, referral_to, 'Admins', existed).deliver_now if admins.present?
    ReferralClientMailer.send_to(managers, referral_from, referral_to, 'Managers', existed).deliver_now if managers.present?
  end
end
