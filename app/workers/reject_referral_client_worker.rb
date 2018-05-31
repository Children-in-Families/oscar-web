class RejectReferralClientWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(user_name, referred_to, referred_from, client_name)
    Organization.switch_to referred_from
    admins = User.admins.non_locked.referral_notification_email
    managers = User.managers.non_locked.referral_notification_email

    RejectReferralClientMailer.client_rejection_email(admins, referred_to, client_name, user_name, 'Admin').deliver_now if admins.present?
    RejectReferralClientMailer.client_rejection_email(managers, referred_to, client_name, user_name, 'Manager').deliver_now if managers.present?
  end
end
